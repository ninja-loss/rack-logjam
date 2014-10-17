module Rack
  module Logjam
    module Formatters
      class TextPlain < ::Rack::Logjam::Formatters::Base

        def render
          content
        end

      end
    end
  end
end
