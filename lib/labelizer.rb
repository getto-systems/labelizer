require "i18n"
require "active_support/inflector"

require "labelizer/version"
require "labelizer/container"

module Labelizer
  def self.included(base)
    base.send :extend, ClassMethods
  end

  def labelized
    @labelized ||= Container.new(self.class.labelized.instance_variable_get(:@keys)){|h,attr|
      h[attr] = self.class.labelized[attr][__send__(attr)]
    }
  end

  module ClassMethods
    def labelized
      @labelized
    end

    private

      def labelize(attr_name, label_types, converter: {})
        label_types = label_types.map(&:to_sym)

        define_method :"#{attr_name}_labelized" do
          labelized[attr_name]
        end

        label_types.each do |label_type|
          define_method :"#{attr_name}_#{label_type}" do
            labelized[attr_name][label_type]
          end
        end

        model = self.to_s.underscore
        @labelized ||= Container.new([]){|attr_labelized,attr|
          attr_labelized[attr] = Container.new(__send__(attr.to_s.pluralize), accept_array_key: true){|value_labelized,value|
            unless attr_labelized[attr].has_key?(value)
              Container.new(label_types){|h,label_type|
                h[label_type] = value.map{|val| value_labelized[val][label_type]}
              }
            else
              value_labelized[value] = Container.new(label_types){|h,label_type|
                result = ::I18n.translate(
                  "labelizer.#{model}.#{attr}.#{value}.#{label_type}",
                  default: [
                    :"labelizer.#{model}.#{attr}.#{label_type}",
                    :"labelizer.#{model}.#{label_type}",
                    :"labelizer.#{label_type}",
                    "",
                  ],
                )
                if c = converter[label_type]
                  result = c[result]
                end
                h[label_type] = result
              }
            end
          }
        }

        @labelized.instance_variable_get(:@keys) << attr_name
        @labelized.singleton_class.class_eval do
          define_method attr_name do
            @hash[attr_name]
          end
        end
      end
  end
end
