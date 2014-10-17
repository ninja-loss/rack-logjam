module Rack
  module Logjam
    module Formatters
      class Nil < ::Rack::Logjam::Formatters::Base

        def render
          "No formatter defined for mime-type #{format}"
        end

      end
    end
  end
end
