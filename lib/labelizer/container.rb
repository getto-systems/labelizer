module Labelizer
  class Container
    include Enumerable

    def initialize(keys,&block)
      case keys
      when Hash
        @keys = keys.keys
        @values = keys.values
        @map = keys.invert
      else
        @keys = keys
        @values = []
        @map = {}
      end
      @hash = Hash.new(&block)

      normalized_keys = @keys
      self.singleton_class.class_eval do
        normalized_keys.each do |key|
          define_method key do
            @hash[key]
          end
        end
      end
    end

    def [](key)
      return @hash[key] if @keys.include?(key)
      return @hash[@map[key]] if @values.include?(key)
      raise KeyError, "key: #{key.inspect} not found"
    end

    def each
      @keys.each do |key|
        yield key, @hash[key]
      end
    end
  end
end
