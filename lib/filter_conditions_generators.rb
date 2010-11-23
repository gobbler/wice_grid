module Wice
  class FilterConditionsGenerator   #:nodoc:

    cattr_accessor :handled_type
    @@handled_type = HashWithIndifferentAccess.new

    def initialize(field, criteria)   #:nodoc:
      @field = field
      @criteria = criteria
    end
    
    def generate_conditions(opts)
      raise "must be implemented"
    end
  end

#   class FilterConditionsGeneratorCustomFilter < FilterConditionsGenerator #:nodoc:

#     def generate_conditions(opts)   #:nodoc:
#       if opts.empty?
#         Wice.log "empty parameters for the grid custom filter"
#         return false
#       end
#       opts = (opts.kind_of?(Array) && opts.size == 1) ? opts[0] : opts

#       if opts.kind_of?(Array)
#         opts_with_special_values, normal_opts = opts.partition{|v| ::Wice::GridTools.special_value(v)}

#         conditions_ar = if normal_opts.size > 0
#           [" #{@field.alias_or_table_name(table_alias)}.#{@field.name} IN ( " + (['?'] * normal_opts.size).join(', ') + ' )'] + normal_opts
#         else
#           []
#         end

#         if opts_with_special_values.size > 0
#           special_conditions = opts_with_special_values.collect{|v| " #{@field.alias_or_table_name(table_alias)}.#{@field.name} is " + v}.join(' or ')
#           if conditions_ar.size > 0
#             conditions_ar[0] = " (#{conditions_ar[0]} or #{special_conditions} ) "
#           else
#             conditions_ar = " ( #{special_conditions} ) "
#           end
#         end
#         conditions_ar
#       else
#         if ::Wice::GridTools.special_value(opts)
#           " #{@field.alias_or_table_name(table_alias)}.#{@field.name} is " + opts
#         else
#           [" #{@field.alias_or_table_name(table_alias)}.#{@field.name} = ?", opts]
#         end
#       end
#     end

#   end

#   class FilterConditionsGeneratorBoolean < FilterConditionsGenerator  #:nodoc:
#     @@handled_type[Boolean] = self

#     def  generate_conditions(opts)   #:nodoc:
#       unless (opts.kind_of?(Array) && opts.size == 1)
#         Wice.log "invalid parameters for the grid boolean filter - must be an one item array: #{opts.inspect}"
#         return false
#       end
#       opts = opts[0]
#       if opts == 'f'
#         [" (#{@field.alias_or_table_name(table_alias)}.#{@field.name} = ? or #{@field.alias_or_table_name(table_alias)}.#{@field.name} is null) ", false]
#       elsif opts == 't'
#         [" #{@field.alias_or_table_name(table_alias)}.#{@field.name} = ?", true]
#       else
#         nil
#       end
#     end
#   end

  class FilterConditionsGeneratorString < FilterConditionsGenerator  #:nodoc:
    @@handled_type[String] = self

    def generate_conditions(opts)   #:nodoc:
      negation = nil
      if opts.kind_of? String
        string_fragment = opts
      elsif (opts.kind_of? Hash) && opts.has_key?(:v)
        string_fragment = opts[:v]
        #negation = opts[:n] == '1' ? 'NOT' : ''
      else
        Wice.log "invalid parameters for the grid string filter - must be a string: #{opts.inspect} or a Hash with keys :v and :n"
        return false
      end
      if string_fragment.empty?
        Wice.log "invalid parameters for the grid string filter - empty string"
        return false
      end
      @criteria.where(@field.name.to_s => /#{string_fragment}/)
      return true
    end

  end

#   class FilterConditionsGeneratorInteger < FilterConditionsGenerator  #:nodoc:
#     @@handled_type[Integer] = self
#     @@handled_type[Float]   = self
#     @@handled_type[BigDecimal] = self

#     def  generate_conditions(opts)   #:nodoc:
#       unless opts.kind_of? Hash
#         Wice.log "invalid parameters for the grid integer filter - must be a hash"
#         return false
#       end
#       conditions = [[]]
#       if opts[:fr]
#         if opts[:fr] =~ /\d/
#           conditions[0] << " #{@field.alias_or_table_name(table_alias)}.#{@field.name} >= ? "
#           conditions << opts[:fr]
#         else
#           opts.delete(:fr)
#         end
#       end

#       if opts[:to]
#         if opts[:to] =~ /\d/
#           conditions[0] << " #{@field.alias_or_table_name(table_alias)}.#{@field.name} <= ? "
#           conditions << opts[:to]
#         else
#           opts.delete(:to)
#         end
#       end

#       if conditions.size == 1
#         Wice.log "invalid parameters for the grid integer filter - either range limits are not supplied or they are not numeric"
#         return false
#       end

#       conditions[0] = conditions[0].join(' and ')

#       return conditions
#     end
#   end

  class FilterConditionsGeneratorDate < FilterConditionsGenerator  #:nodoc:
    @@handled_type[Date]      = self
    @@handled_type[DateTime]  = self
    @@handled_type[Time] = self

    def generate_conditions(opts)   #:nodoc:
      @criteria.where(@field.name.to_sym.gt => opts[:fr]) if opts[:fr]
      @criteria.where(@field.name.to_sym.lt => opts[:to]) if opts[:to]
      opts[:fr] || opts[:to]
    end
  end
end
