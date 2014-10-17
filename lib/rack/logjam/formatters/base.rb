module Rack
  module Logjam
    module Formatters
      class Base

        def initialize( content, format=nil )
          @content = content
          @format  = format
        end

        def render
          "You must implement #{self.class.name}#render in order to render a #{format} response"
        end

      protected

        attr_reader :content,
                    :format

      end
    end
  end
end
