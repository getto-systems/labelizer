require "i18n"

require "labelizer/version"

module Labelizer
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def labelize(attr, labels, converter: {})
      @labelizer_converters ||= {}
      @labelizer_converters[attr.to_sym] = converter

      define_method :"#{attr}_labelized" do
        self.class.labelized[attr][__send__(attr)]
      end

      labels.each do |label|
        define_method :"#{attr}_#{label}" do
          self.class.labelized[attr][__send__(attr)][label]
        end
      end
    end
    def labelized
      model = model_name.i18n_key
      @labelized ||= Hash.new{|h,attr|
        converters = @labelizer_converters && @labelizer_converters[attr.to_sym]
        h[attr] = Hash.new{|h,value|
          h[value] = Hash.new{|h,label|
            result = ::I18n.translate(
              "labelizer.#{model}.#{attr}.#{value}.#{label}",
              default: [
                :"labelizer.#{model}.#{attr}.#{label}",
                :"labelizer.#{model}.#{label}",
                :"labelizer.#{label}",
                value,
              ],
              raise: true,
            ) rescue value
            if converter = converters && converters[label.to_sym]
              result = converter[result]
            end
            h[value] = result
          }
        }
      }
    end
  end
end
