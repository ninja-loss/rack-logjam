require 'jsonpath'
require 'mime/types'

module Rack
  module Logjam
    class Logger

      def log_request( env )
        _logger.info <<-end_info
[#{ANSI.green { 'api' }}] #{ANSI.cyan { '--- Request Env ---' }}
#{ANSI.magenta { JSON.pretty_generate( request_log_data( env )) }}
[#{ANSI.green { 'api' }}] #{ANSI.cyan { '--- Request Body ---' }}
#{ANSI.cyan { formatted_request_body( env ) }}
end_info
      end

      def log_response( env, status, headers, response )
        _logger.info <<-end_info
[#{ANSI.green { 'api' }}] #{ANSI.cyan { '--- Response ---' }}
Status: #{status}
Headers: #{headers.inspect}
Body:
#{ANSI.cyan { format_body( (response.body rescue response), accept( env ), env ) }}
        end_info
      end

    protected

      def request_log_data( env )
        request_data = {
          content_type:   content_type( env ),
          content_length: env['CONTENT_LENGTH'],
          accept:         accept( env ),
          accept_version: env['HTTP_ACCEPT_VERSION'],
          method:         env['REQUEST_METHOD'],
          path:           path_info( env ),
          query:          query( env )
        }
        #request_data[:user_id] = current_user.id if current_user
        request_data
      end

      def content_type( env )
        env['CONTENT_TYPE']
      end

      def accept( env )
        env['HTTP_ACCEPT']
      end

      def path_info( env )
        env['PATH_INFO']
      end

      def query( env )
        URI.unescape( env['QUERY_STRING'] )
      end

      def formatted_request_body( env )
        format_body( rack_input_content( env ), content_type( env ), env )
      end

      def format_body( body, format, env )
        filter = fetch_filter( format, body )
        filtered = filter.render

        formatter = fetch_formatter( format, body ).new( filtered, format )
        formatter.render
      end

      def fetch_filter( format, body )
        klass, filters = Rack::Logjam::Filters.get( format )
        klass.new( body, filters )
      end

      def fetch_formatter( format, body )
        return Rack::Logjam::Array if body.is_a?( Array )
        return Rack::Logjam::Empty if body.strip.nil? || body.strip.empty?
        Rack::Logjam::Formatters.get( format )
      end

      def rack_input_content( env )
        ( rack_input = env['rack.input'] ).read.tap do |content|
          rack_input.rewind
        end
      end

      def _logger
        ::Rack::Logjam::logger
      end

    end
  end
end
