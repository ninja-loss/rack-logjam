module Rack
  module Logjam
    module Filters

      autoload :Base, 'rack/logjam/filters/base'
      autoload :Json, 'rack/logjam/filters/json'
      autoload :Nil,  'rack/logjam/filters/nil'

      @registry = {}

      def self.registry
        @registry
      end

      def self.register( mime_type, formatter_klass_name, filters )
        registry.merge!( mime_type => [formatter_klass_name, filters] )
      end

      def self.get( mime_type )
        const_name, filters = registry.fetch( mime_type, [:Nil, []] )
        return self::const_get( const_name ), filters
      end

    end
  end
end
