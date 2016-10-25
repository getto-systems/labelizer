require "i18n"

require "labelizer/version"

module Labelizer
  class << self
    def configure
      yield config
    end

    private

      def config
        @config ||= OpenStruct.new
      end
  end

  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def labelize(*attrs)
      attrs.each do |attr|
        define_method :"#{attr}_labelized" do
          self.class.labelized[attr][__send__(attr)]
        end

        (Labelizer.__send__(:config).labels || []).each do |label|
          define_method :"#{attr}_#{label}" do
            self.class.labelized[attr][__send__(attr)][label]
          end
        end
      end
    end
    def labelized
      model = model_name.i18n_key
      @labelized ||= Hash.new{|h,attr|
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
            if converter = (Labelizer.__send__(:config).converter || {})[label.to_sym]
              result = converter[result]
            end
            h[value] = result
          }
        }
      }
    end
  end
end
