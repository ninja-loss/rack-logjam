#require 'json'
require 'grape/middleware/base'

module Rack
  module Logjam
    module Grape
      class Middleware < ::Grape::Middleware::Base

        def before
          logger.log_request( env )
        end

        def after
          if @app_response.nil?
            ::Rack::Logjam::logger.info "@app_response is nil. WTF Grape? https://github.com/ruby-grape/grape/issues/1265"
            return
          end
          status = @app_response.status
          headers = @app_response.header
          body = @app_response.body.last

          #logger.log_response( env, status, headers, response )
          logger.log_response( env, status, headers, body )

          @app_response
        end

      protected

        def api_request?( env )
          true
          #path_info( env ) =~ /^\/api\//
        end

        def path_info( env )
          env['PATH_INFO']
        end

        def logger
          Rack::Logjam::Logger.new
        end

        def request_log_data
          request_data = {
            auth_token:     env['HTTP_X_NCITE_AUTH_TOKEN'],
            content_type:   content_type,
            content_length: env['CONTENT_LENGTH'],
            accept:         env['HTTP_ACCEPT'],
            accept_version: env['HTTP_ACCEPT_VERSION'],
            method:         env['REQUEST_METHOD'],
            path:           env['PATH_INFO'],
            query:          env['QUERY_STRING']
          }
          #request_data[:user_id] = current_user.id if current_user
          request_data
        end

        def response_log_data
          {
            description: env['api.endpoint'].options[:route_options][:description],
            source_file: env['api.endpoint'].block.source_location[0][(::Rails.root.to_s.length+1)..-1],
            source_line: env['api.endpoint'].block.source_location[1]
          }
        end

        def content_type
          env['CONTENT_TYPE']
        end

        def formatted_request_body
          body = env['rack.input'].read
          return ANSI.yellow { 'EMPTY' } if body.blank?

          if content_type == Mime::JSON.to_s
            return ANSI.cyan { JSON.pretty_generate( JSON.parse( body )) }
          end

          nil
        end

        def formatted_response_body
          ANSI.cyan { JSON.pretty_generate(JSON.parse( @app_response.last.body.last )) }
        end

      end
    end
  end
end
