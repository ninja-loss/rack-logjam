module Rack
  module Logjam
    class Configuration

      def logger=( logger )
        Rack::Logjam::logger = logger
      end

      def register_filter( mime_type, filter_symbol_or_constant, filters )
        Rack::Logjam::Filters.register( mime_type, filter_symbol_or_constant, filters )
      end

      def register_formatter( mime_type, formatter_symbol_or_constant )
        Rack::Logjam::Formatters.register( mime_type, formatter_symbol_or_constant )
      end

    end
  end
end
