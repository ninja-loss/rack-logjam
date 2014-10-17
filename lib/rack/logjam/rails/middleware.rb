require 'action_dispatch/http/mime_type'
require 'jsonpath'

module Rack
  module Logjam
    module Rails
      class Middleware

        def initialize( app )
          @app = app
        end

        def call( env )
          before env

          app.call( env ).tap do |rack_response|
            after env, *rack_response
          end
        end

      protected

        attr_reader :app

        def before( env )
          return unless api_request?( env )

          logger.log_request( env )
        end

        def after( env, status, headers, response )
          return unless api_request?( env )

          logger.log_response( env, status, headers, response )
        end

        def api_request?( env )
          path_info( env ) =~ /^\/api\//
        end

        def path_info( env )
          env['PATH_INFO']
        end

        def logger
          Rack::Logjam::Logger.new
        end

      end
    end
  end
end
