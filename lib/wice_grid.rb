# encoding: UTF-8
require 'wice_grid_misc.rb'
require 'wice_grid_core_ext.rb'
require 'grid_renderer.rb'
require 'helpers/wice_grid_view_helpers.rb'
require 'helpers/wice_grid_misc_view_helpers.rb'
require 'helpers/wice_grid_serialized_queries_view_helpers.rb'
require 'helpers/wice_grid_view_helpers.rb'
require 'helpers/js_calendar_helpers.rb'
require 'grid_output_buffer.rb'
require 'wice_grid_controller.rb'
require 'mongoid_field'
require 'wice_grid_spreadsheet.rb'
require 'wice_grid_serialized_queries_controller.rb'
require 'js_adaptors/js_adaptor.rb'
require 'js_adaptors/jquery_adaptor.rb'
require 'js_adaptors/prototype_adaptor.rb'
require 'view_columns.rb'


ActionController::Base.send(:helper_method, :wice_grid_custom_filter_params)

module Wice

  class WiceGridRailtie < Rails::Railtie

    initializer "wice_grid_railtie.configure_rails_initialization" do |app|
      ActionController::Base.send(:include, Wice::Controller)
      # Mongoid::Field.send(:include, ::Wice::MongoidField)
      Mongoid::Fields.send(:include, ::Wice::MongoidField)
      Mongoid::Fields::Serializable::Time.send(:include, ::Wice::MongoidField)
      Mongoid::Fields::Serializable::Object.send(:include, ::Wice::MongoidField)
      ::ActionView::Base.class_eval { include Wice::GridViewHelper }

      [ActionView::Helpers::AssetTagHelper,
       ActionView::Helpers::TagHelper,
       ActionView::Helpers::JavaScriptHelper,
       ActionView::Helpers::FormTagHelper].each do |m|
        JsCalendarHelpers.send(:include, m)
      end
    end

    rake_tasks do
      load 'tasks/wice_grid_tasks.rake'
    end
  end

  class WiceGrid

    attr_reader :klass, :name, :resultset, :custom_order, :query_store_model, :options, :controller
    attr_reader :ar_options, :status, :export_to_csv_enabled, :csv_file_name, :saved_query, :extra_filter
    attr_writer :renderer
    attr_accessor :output_buffer, :view_helper_finished, :csv_tempfile

    # core workflow methods START

    def initialize(klass, controller, opts = {})  #:nodoc:
      @controller = controller

      unless klass.kind_of?(Class) && klass.ancestors.index(Mongoid::Document)
        raise WiceGridArgumentError.new("The model class (second argument) must be a Class derived from Mongoid::Document")
      end
      # validate :with_resultset & :with_paginated_resultset
      [:with_resultset, :with_paginated_resultset].each do |callback_symbol|
        unless [NilClass, Symbol, Proc].index(opts[callback_symbol].class)
          raise WiceGridArgumentError.new(":#{callback_symbol} must be either a Proc or Symbol object")
        end
      end

      opts[:order_direction].downcase! if opts[:order_direction].kind_of?(String)

      # validate :order_direction
      if opts[:order_direction] && ! (opts[:order_direction] == 'asc'  ||
                                      opts[:order_direction] == :asc   ||
                                      opts[:order_direction] == 'desc' ||
                                      opts[:order_direction] == :desc)
        raise WiceGridArgumentError.new(":order_direction must be either 'asc' or 'desc'.")
      end

      # options that are understood
      @options = {
        :conditions           => nil,
        :csv_file_name        => nil,
        :custom_order         => {},
        :enable_export_to_csv => Defaults::ENABLE_EXPORT_TO_CSV,
        :group                => nil,
        :include              => nil,
        :joins                => nil,
        :name                 => Defaults::GRID_NAME,
        :order                => nil,
        :order_direction      => Defaults::ORDER_DIRECTION,
        :per_page             => Defaults::PER_PAGE,
        :saved_query          => nil,
        :select               => nil,
        :total_entries        => nil,
        :with_paginated_resultset  => nil,
        :with_resultset       => nil
      }

      # validate parameters
      opts.assert_valid_keys(@options.keys)

      @options.merge!(opts)
      @export_to_csv_enabled = @options[:enable_export_to_csv]
      @csv_file_name = @options[:csv_file_name]

      case @name = @options[:name]
      when String
      when Symbol
        @name = @name.to_s
      else
        raise WiceGridArgumentError.new("name of the grid should be a string or a symbol")
      end
      raise WiceGridArgumentError.new("name of the grid can only contain alphanumeruc characters") unless @name =~ /^[a-zA-Z\d_]*$/

      @klass = klass
      @criteria = Mongoid::Criteria.new(@klass)
      @has_any_filter_criteria = false
      @status = HashWithIndifferentAccess.new

      if @options[:order]
        @options[:order] = @options[:order].to_s
        @options[:order_direction] = @options[:order_direction].to_s

        @status[:order_direction] = @options[:order_direction]
        @status[:order] = @options[:order]

      end
      @status[:total_entries] = @options[:total_entries]
      @status[:per_page] = @options[:per_page]
      @status[:page] = @options[:page]
      @status[:conditions] = @options[:conditions]
      @status[:f] = @options[:f]

      process_loading_query
      process_params
      @criteria_formed = false
    end

    def add_criteria(extra)
      @extra_filter = extra
      @criteria = @criteria.merge(extra)
    end
    
    def has_any_filter_criteria?
      @has_any_filter_criteria
    end
    
    def has_more_to_show?
      @status[:per_page].to_i < resultset.count
    end
    # A block executed from within the plugin to process records of the current page.
    # The argument to the callback is the array of the records. See the README for more details.
    def with_paginated_resultset(&callback)
      @options[:with_paginated_resultset] = callback
    end

    # A block executed from within the plugin to process all records browsable through
    # all pages with the current filters. The argument to
    # the callback is a lambda object which returns the list of records when called. See the README for the explanation.
    def with_resultset(&callback)
      @options[:with_resultset] = callback
    end

    def process_loading_query #:nodoc:
      @saved_query = nil
      if params[name] && params[name][:q]
        @saved_query = load_query(params[name][:q])
        params[name].delete(:q)
      elsif @options[:saved_query]
        if @options[:saved_query].is_a? ActiveRecord::Base
          @saved_query = @options[:saved_query]
        else
          @saved_query = load_query(@options[:saved_query])
        end
      else
        return
      end

      unless @saved_query.nil?
        params[name] = HashWithIndifferentAccess.new if params[name].blank?
        [:f, :order, :order_direction].each do |key|
          if @saved_query.query[key].blank?
            params[name].delete(key)
          else
            params[name][key] = @saved_query.query[key]
          end
        end
      end
    end

    def process_params  #:nodoc:
      if this_grid_params
        @status.merge!(this_grid_params)
        @status.delete(:export) unless self.export_to_csv_enabled
      end
    end

    def declare_column(field_name, custom_filter_active)  #:nodoc:
      field = @klass.fields[field_name]
      raise WiceGridArgumentError.new("Model #{@klass.name} does not have field '#{field_name}'.! ") unless field

      criteria_added, criteria = field.wice_add_filter_criteria(@status[:f], @klass, custom_filter_active)
      @criteria = @criteria.merge(criteria) if criteria
      
      @status[:f].delete(field_name) if @status[:f] && !criteria_added

      @has_any_filter_criteria ||= criteria_added
      [field, nil , true]
    end

    def form_criteria(opts = {})  #:nodoc:

      return if @criteria_formed
      @criteria_formed = true unless opts[:forget_generated_options]

      # validate @status[:order_direction]
      @status[:order_direction] = case @status[:order_direction]
      when /desc/i
        'desc'
      when /asc/i
        'asc'
      else
        ''
      end

      @status.delete(:f) if !@has_any_filter_criteria

      if !opts[:skip_ordering] && @status[:order]
        order_by = @status[:order].to_sym.send( @status[:order_direction].to_sym )
        @criteria = @criteria.order_by(order_by)
      end

      @criteria = @criteria.limit(@status[:per_page].to_i)
#       #fix-this, Criteria must respect options
#       if self.output_html?
#         @criteria[:per_page] = if all_record_mode?
#           # reset the :pp value in all records mode
#           @status[:pp] = count_resultset_without_paging_without_user_filters
#         else
#           @status[:per_page]
#         end

#         @criteria[:page] = @status[:page]
#         @criteria[:total_entries] = @status[:total_entries] if @status[:total_entries]
#       end

#       @criteria[:joins]   = @options[:joins]
#       @criteria[:include] = @options[:include]
#       @criteria[:group] = @options[:group]
#       @criteria[:select]  = @options[:select]
    end

    def read  #:nodoc:
      form_criteria
      with_exclusive_scope do
        @criteria.options[:limit] = nil if @resultset = self.output_csv?
        @resultset = @criteria
      end
      invoke_resultset_callbacks
    end


    # core workflow methods END

    # Getters

    def filter_params(view_column)  #:nodoc:
      return (@status[:f][view_column.attribute_name] || "") if @status[:f]
      ""
    end

    def resultset  #:nodoc:
      self.read unless @resultset # database querying is late!
      @resultset
    end

    def each   #:nodoc:
      self.read unless @resultset # database querying is late!
      @resultset.each do |r|
        yield r
      end
    end

    def ordered_by?(column)  #:nodoc:
      return nil if @status[:order].blank?
      @status[:order] == column.attribute_name
    end

    def ordered_by  #:nodoc:
      @status[:order]
    end


    def order_direction  #:nodoc:
      @status[:order_direction]
    end

    def filtering_on?  #:nodoc:
      not @status[:f].blank?
    end

    def filtered_by  #:nodoc:
      @status[:f].nil? ? [] : @status[:f].keys
    end

    def filtered_by?(view_column)  #:nodoc:
      @status[:f] && @status[:f].has_key?(view_column.attribute_name)
    end

    def get_state_as_parameter_value_pairs(including_saved_query_request = false) #:nodoc:
      res = []
      unless status[:f].blank?
        status[:f].parameter_names_and_values([name, 'f']).collect do |param_name, value|
          if value.is_a?(Array)
            param_name_ar = param_name + '[]'
            value.each do |v|
              res << [param_name_ar, v]
            end
          else
            res << [param_name, value]
          end
        end
      end

      if including_saved_query_request && @saved_query
        res << ["#{name}[q]", @saved_query.id ]
      end

      [:order, :order_direction].select{|parameter|
        status[parameter]
      }.collect do |parameter|
        res << ["#{name}[#{parameter}]", status[parameter] ]
      end

      res
    end

    def count  #:nodoc:
      form_criteria(:skip_ordering => true, :forget_generated_options => true)
      @klass.count(:conditions => @criteria[:conditions], :joins => @criteria[:joins], :include => @criteria[:include], :group => @criteria[:group])
    end

    alias_method :size, :count

    def empty?  #:nodoc:
      self.count == 0
    end

    # with this variant we get even those values which do not appear in the resultset
    def distinct_values_for_column(column)  #:nodoc:
      res = column.model_klass.find(:all, :select => "distinct #{column.name}", :order => "#{column.name} asc").collect{|ar|
        ar[column.name]
      }.reject{|e| e.blank?}.map{|i|[i,i]}
    end


    def distinct_values_for_column_in_resultset(messages)  #:nodoc:
      uniq_vals = Set.new

      resultset_without_paging_without_user_filters.each do |ar|
        v = ar.deep_send(*messages)
        uniq_vals << v unless v.nil?
      end
      return uniq_vals.to_a.map{|i|
        if i.is_a?(Array) && i.size == 2
          i
        elsif i.is_a?(Hash) && i.size == 1
          i.to_a.flatten
        else
          [i,i]
        end
      }.sort{|a,b| a[0]<=>b[0]}
    end

    def output_csv? #:nodoc:
      @status[:export] == 'csv'
    end

    def output_html? #:nodoc:
      @status[:export].blank?
    end

    def all_record_mode? #:nodoc:
      @status[:pp]
    end

    def dump_status #:nodoc:
      "   params: #{params[name].inspect}\n"  +
      "   status: #{@status.inspect}\n" +
      "   ar_options #{@criteria.inspect}\n"
    end


    def selected_records #:nodoc:
      STDERR.puts "WiceGrid: Parameter :#{selected_records} is deprecated, use :#{all_pages_records} or :#{current_page_records} instead!"
      all_pages_records
    end

    # Returns the list of objects browsable through all pages with the current filters.
    # Should only be called after the +grid+ helper.
    def all_pages_records
      raise WiceGridException.new("all_pages_records can only be called only after the grid view helper") unless self.view_helper_finished
      resultset_without_paging_with_user_filters
    end

    # Returns the list of objects displayed on current page. Should only be called after the +grid+ helper.
    def current_page_records
      raise WiceGridException.new("current_page_records can only be called only after the grid view helper") unless self.view_helper_finished
      @resultset
    end



    protected

    def invoke_resultset_callback(callback, argument) #:nodoc:
      case callback
      when Proc
        callback.call(argument)
      when Symbol
        @controller.send(callback, argument)
      end
    end

    def invoke_resultset_callbacks #:nodoc:
      invoke_resultset_callback(@options[:with_paginated_resultset], @resultset)
      invoke_resultset_callback(@options[:with_resultset], lambda{self.send(:resultset_without_paging_with_user_filters)})
    end

    def with_exclusive_scope #:nodoc:
      yield
    end

    def complete_column_name(col_name)  #:nodoc:
      if col_name.index('.') # already has a table name
        col_name
      else # add the default table
        "#{@klass.collection_name}.#{col_name}"
      end
    end

    def params  #:nodoc:
      @controller.params
    end

    def this_grid_params  #:nodoc:
      params[name]
    end


    def resultset_without_paging_without_user_filters  #:nodoc:
      form_criteria
      with_exclusive_scope do
        @klass.find(:all, :joins => @criteria[:joins],
                          :include => @criteria[:include],
                          :group => @criteria[:group],
                          :conditions => @options[:conditions])
      end
    end

    def count_resultset_without_paging_without_user_filters  #:nodoc:
      form_criteria
      with_exclusive_scope do
        @klass.count(
          :joins => @criteria[:joins],
          :include => @criteria[:include],
          :group => @criteria[:group],
          :conditions => @options[:conditions]
        )
      end
    end


    def resultset_without_paging_with_user_filters  #:nodoc:
      form_criteria
      with_exclusive_scope do
        @klass.find(:all, :joins      => @criteria[:joins],
                          :include    => @criteria[:include],
                          :group      => @criteria[:group],
                          :conditions => @criteria[:conditions],
                          :order      => @criteria[:order])
      end
    end


    def load_query(query_id) #:nodoc:
      @query_store_model ||= Wice::get_query_store_model
      query = @query_store_model.find_by_id_and_grid_name(query_id, self.name)
      Wice::log("Query with id #{query_id} for grid '#{self.name}' not found!!!") if query.nil?
      query
    end


  end

  # routines called from WiceGridExtentionToActiveRecordColumn (ActiveRecord::ConnectionAdapters::Column) or FilterConditionsGenerator classes
  module GridTools   #:nodoc:
    class << self
      def special_value(str)   #:nodoc:
        str =~ /^\s*(not\s+)?null\s*$/i
      end

      # create a Time instance out of parameters
      def params_2_datetime(par)   #:nodoc:
        return nil if par.blank?
        params =  [par[:year], par[:month], par[:day], par[:hour], par[:minute]].collect{|v| v.blank? ? nil : v.to_i}
        begin
          Time.local(*params)
        rescue ArgumentError, TypeError
          nil
        end
      end

      # create a Date instance out of parameters
      def params_2_date(par)   #:nodoc:
        return nil if par.blank?
        params =  [par[:year], par[:month], par[:day]].collect{|v| v.blank? ? nil : v.to_i}
        begin
          Date.civil(*params)
        rescue ArgumentError, TypeError
          nil
        end
      end

    end
  end



end
