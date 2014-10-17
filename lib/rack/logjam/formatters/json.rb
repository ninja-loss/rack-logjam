require 'multi_json'

module Rack
  module Logjam
    module Formatters
      class Json < ::Rack::Logjam::Formatters::Base

        def render
          hash = MultiJson.load( content )
          MultiJson.dump( hash, pretty: true )
        end

      end
    end
  end
end
