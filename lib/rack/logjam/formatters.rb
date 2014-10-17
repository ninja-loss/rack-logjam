module Rack
  module Logjam
    module Formatters

      autoload :Array,          'rack/logjam/formatters/array'
      autoload :Base,           'rack/logjam/formatters/base'
      autoload :Empty,          'rack/logjam/formatters/empty'
      autoload :FormUrlencoded, 'rack/logjam/formatters/form_urlencoded'
      autoload :Json,           'rack/logjam/formatters/json'
      autoload :Nil,            'rack/logjam/formatters/nil'
      autoload :TextPlain,      'rack/logjam/formatters/text_plain'
      autoload :Xml,            'rack/logjam/formatters/xml'

      @registry = {}

      def self.registry
        @registry
      end

      def self.register( mime_type, formatter_klass_name )
        registry.merge!( mime_type => formatter_klass_name )
      end

      def self.get( mime_type )
        const_name = registry.fetch( mime_type, :Nil )
        const_name.is_a?( Class ) ?
          const_name :
          self::const_get( const_name )
      end

    end
  end
end
