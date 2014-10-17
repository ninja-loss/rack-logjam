module Rack
  module Logjam
    module Formatters
      class Array < ::Rack::Logjam::Formatters::Base

        def render
          Json.new( content, format ).render
        end

      end
    end
  end
end
