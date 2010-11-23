module Wice
  # to be mixed in into Mongoid::Field
  module MongoidField
    def wice_add_filter_criteria(all_filter_params, criteria, custom_filter_active)  #:nodoc:
      request_params = all_filter_params ? all_filter_params[name] : nil
      return nil unless request_params

      # Preprocess incoming parameters for datetime, if what's coming in is
      # a datetime (with custom_filter it can be anything else, and not
      # the datetime hash {:fr => ..., :to => ...})
      if (self.type == DateTime) && request_params.is_a?(Hash)
        [:fr, :to].each do |sym|
          if request_params[sym]
            if request_params[sym].is_a?(String)
              request_params[sym] = Wice::Defaults::DATETIME_PARSER.call(request_params[sym])
            elsif request_params[sym].is_a?(Hash)
              request_params[sym] = ::Wice::GridTools.params_2_datetime(request_params[sym])
            end
          end
        end

        # Preprocess incoming parameters for date, if what's coming in is
        # a date (with custom_filter it can be anything else, and not
        # the date hash {:fr => ..., :to => ...})
        if self.type == Date && request_params.is_a?(Hash)
          [:fr, :to].each do |sym|
            if request_params[sym]
              if request_params[sym].is_a?(String)
                request_params[sym] = Wice::Defaults::DATE_PARSER.call(request_params[sym])
              elsif request_params[sym].is_a?(Hash)
                request_params[sym] = ::Wice::GridTools.params_2_date(request_params[sym])
              end
            end
          end
        end
      end

      processor_klass =  ::Wice::FilterConditionsGeneratorCustomFilter if custom_filter_active
      processor_klass = ::Wice::FilterConditionsGenerator.handled_type[self.type] unless processor_klass
      unless processor_klass
        Wice.log("No processor for database type #{column_type}!!!")
        return nil
      end
      processor_klass.new(self, criteria).generate_conditions(request_params)
    end

  end
end
