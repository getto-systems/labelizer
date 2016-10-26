module Labelizer
  class Container
    include Enumerable

    def initialize(keys, accept_array_key: false, &block)
      @data = {
        is_accept_array_key: accept_array_key,
      }

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
          if key.is_a?(Symbol) || key.is_a?(String)
            define_method key do
              @hash[key]
            end
          end
        end
      end
    end

    def [](key)
      return @hash[key] if @keys.include?(key)
      return @hash[@map[key]] if @values.include?(key)

      if @data[:is_accept_array_key]
        if key.respond_to?(:each)
          if key.all?{|k| @keys.include?(k)}
            return @hash[key]
          end
          if key.all?{|k| @values.include?(k)}
            return @hash[key.map{|k| @map[k]}]
          end
        end
      end

      raise KeyError, "key: #{key.inspect} not found"
    end
    def has_key?(key)
      @keys.include?(key) || @values.include?(key)
    end
    def size
      @keys.size
    end

    def each
      @keys.each do |key|
        yield key, @hash[key]
      end
    end
  end
end
