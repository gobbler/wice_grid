require_relative 'filter_conditions_generators'

module Wice
  # to be mixed in into Mongoid::Field
  module MongoidField
    def wice_add_filter_criteria(all_filter_params, klass, custom_filter_active)  #:nodoc:
      request_params = all_filter_params ? all_filter_params[name] : nil
      return [nil,nil] unless request_params

      # Preprocess incoming parameters for datetime, if what's coming in is
      # a datetime (with custom_filter it can be anything else, and not
      # the datetime hash {"fr" => ..., "to" => ...})
      if (self.type == Time) 
        if request_params.is_a?(Hash)
          ["fr", "to"].each do |sym|
            if request_params[sym]
              if request_params[sym].is_a?(String)
                request_params[sym] = Time.parse(Wice::Defaults::DATETIME_PARSER.call(request_params[sym]).to_s)
              elsif request_params[sym].is_a?(Hash)
                request_params[sym] = Time.parse(::Wice::GridTools.params_2_datetime(request_params[sym]).to_s)
              end
            end
          end
        elsif request_params.is_a?(Array) && request_params.size == 1
          ago = request_params.first
          today = Time.now.beginning_of_day
          agos = {'1 day' => today - 24.hours,
            '1 week' => today - 7.days,
            '1 month' => today - 1.month,
            'ever' => Time.parse("2000-01-01")}
          if agos.keys.include?(ago)
            request_params = {}
            #regular filtering viea 'fr', 'to' field
            request_params[:fr] = agos[ago] 
            custom_filter_active = nil
          end
        end
      end

      # Preprocess incoming parameters for date, if what's coming in is
      # a date (with custom_filter it can be anything else, and not
      # the date hash {"fr" => ..., "to" => ...})
      if self.type == Date && request_params.is_a?(Hash)
        ["fr", "to"].each do |sym|
          if request_params[sym]
            if request_params[sym].is_a?(String)
              request_params[sym] = Wice::Defaults::DATE_PARSER.call(request_params[sym]).to_time
            elsif request_params[sym].is_a?(Hash)
              request_params[sym] = ::Wice::GridTools.params_2_date(request_params[sym]).to_time
            end
          end
        end
      end

      processor_klass =  ::Wice::FilterConditionsGeneratorCustomFilter if custom_filter_active
      processor_klass = ::Wice::FilterConditionsGenerator.handled_type[self.type] unless processor_klass
      unless processor_klass
        Wice.log("No processor for database type #{self.type}!!!")
        return [nil,nil]
      end
      processor = processor_klass.new(self, klass)
      added = processor.generate_conditions(request_params)
      [added, processor.criteria]
    end

  end
end
