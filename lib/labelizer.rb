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
      @labelized ||= Container.new([]){|attr_labelized,attr|
        model = self.to_s.underscore
        values = __send__(attr.to_s.pluralize)
        labelized = Container.new(values, accept_array_key: true){|value_labelized,value|
          data = labelized.instance_variable_get(:@data)
          attr_label_types = data[:label_types]
          attr_converter = data[:converter]

          unless labelized.has_key?(value)
            Container.new(attr_label_types){|h,label_type|
              h[label_type] = value.map{|val| value_labelized[val][label_type]}
            }
          else
            value_labelized[value] = Container.new(attr_label_types){|h,label_type|
              if label_type == :value
                result = value
              else
                result = ::I18n.translate(
                  "labelizer.#{model}.#{attr}.#{value}.#{label_type}",
                  default: [
                    :"labelizer.#{model}.#{attr}.#{label_type}",
                    :"labelizer.#{model}.#{label_type}",
                    :"labelizer.#{label_type}",
                    "",
                  ],
                )
                if c = attr_converter[label_type]
                  result = c[result]
                end
              end
              h[label_type] = result
            }
          end
        }

        labelized.singleton_class.class_eval do
          define_method :pluck do |*require_label_types|
            map{|value,label_type_labelized|
              require_label_types.map{|require_label_type|
                label_type_labelized[require_label_type]
              }
            }
          end
        end

        attr_labelized[attr] = labelized
      }
    end

    private

      def labelize(attr_name, label_types, converter: {})
        label_types = label_types.map(&:to_sym)
        raise ArgumentError, "label types can't include :value" if label_types.include?(:value)

        label_types << :value

        define_method :"#{attr_name}_labelized" do
          labelized[attr_name]
        end

        label_types.each do |label_type|
          define_method :"#{attr_name}_#{label_type}" do
            labelized[attr_name][label_type]
          end
        end

        labelized.instance_variable_get(:@keys) << attr_name
        labelized.singleton_class.class_eval do
          define_method attr_name do
            self[attr_name]
          end
        end

        data = labelized[attr_name].instance_variable_get(:@data)
        data[:label_types] = label_types
        data[:converter] = converter

        labelized[attr_name]
      end
  end
end
