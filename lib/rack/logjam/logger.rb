require 'jsonpath'
require 'mime/types'

module Rack
  module Logjam
    class Logger

      def log_request(env)
        _logger.info "HTTP Request: #{ANSI.magenta { request_log_data(env).inspect }}"
        formatted_body = formatted_request_body(env)
        _logger.info "HTTP Request Body: #{ANSI.cyan { formatted_body }}" if formatted_body
      end

      def log_response(env, status, headers, response)
        _logger.info "HTTP Response: #{status} #{headers.inspect}"
        _logger.info "HTTP Response Body: : #{ANSI.cyan { format_body((response.body rescue response), accept(env), env) }}"
      end

      protected

      def request_log_data(env)
        request_data = {
            content_type: content_type(env),
            content_length: env['CONTENT_LENGTH'],
            accept: accept(env),
            accept_version: env['HTTP_ACCEPT_VERSION'],
            method: env['REQUEST_METHOD'],
            path: path_info(env),
            query: query(env)
        }
        #request_data[:user_id] = current_user.id if current_user
        request_data
      end

      def content_type(env)
        env['CONTENT_TYPE']
      end

      def accept(env)
        env['HTTP_ACCEPT']
      end

      def path_info(env)
        env['PATH_INFO']
      end

      def query(env)
        URI.unescape(env['QUERY_STRING'])
      end

      def formatted_request_body(env)
        format_body(rack_input_content(env), content_type(env), env)
      end

      def format_body(body, format, env)
        return if body.nil? || body.strip.empty?
        return 'Body too large to log' if body.length > 4096
        filter = fetch_filter(format, body)
        filtered = filter.render
        formatter = fetch_formatter(format, body).new(filtered, format)
        formatter.render
      end

      def fetch_filter(format, body)
        klass, filters = Rack::Logjam::Filters.get(format)
        klass.new(body, filters)
      end

      def fetch_formatter(format, body)
        return Rack::Logjam::Formatters::Array if body.is_a?(Array)
        Rack::Logjam::Formatters.get(format) unless body.nil? || body.strip.empty?
      end

      def rack_input_content(env)
        (rack_input = env['rack.input']).read.tap do |content|
          rack_input.rewind
        end
      end

      def _logger
        ::Rack::Logjam::logger
      end

    end
  end
end
