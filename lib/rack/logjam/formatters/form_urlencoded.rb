module Rack
  module Logjam
    module Formatters
      class FormUrlencoded < ::Rack::Logjam::Formatters::Base

        def render
          URI.unescape( content )
        end

      end
    end
  end
end
