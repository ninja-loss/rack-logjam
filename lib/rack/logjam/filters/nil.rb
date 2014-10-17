module Rack
  module Logjam
    module Filters
      class Nil < Rack::Logjam::Filters::Base

        def render
          content
        end

      end
    end
  end
end
