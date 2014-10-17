module Rack
  module Logjam
    module Formatters
      class Empty < ::Rack::Logjam::Formatters::Base

        def render
          "[EMPTY]"
        end

      end
    end
  end
end
