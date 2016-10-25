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
    def labelize(attr, label_types, converter: {})
      label_types = label_types.map(&:to_sym)

      define_method :"#{attr}_labelized" do
        labelized[attr]
      end

      label_types.each do |label_type|
        define_method :"#{attr}_#{label_type}" do
          labelized[attr][label_type]
        end
      end

      model = self.to_s.underscore
      @labelized ||= Container.new([]){|h,attr|
        h[attr] = Container.new(__send__(attr.to_s.pluralize)){|h,value|
          h[value] = Container.new(label_types){|h,label_type|
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
        }
      }

      @labelized.instance_variable_get(:@keys) << attr
      @labelized.singleton_class.class_eval do
        define_method attr do
          @hash[attr]
        end
      end
    end
    def labelized
      @labelized
    end
  end
end
