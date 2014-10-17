module Rack
  module Logjam
    module Filters
      class Base

        def initialize( content, filters )
          @content = content
          @filters = filters
        end

        def render
          raise NotImplementedError
        end

      protected

        attr_reader :content,
                    :filters

      end
    end
  end
end
