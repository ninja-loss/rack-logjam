require 'nokogiri'

module Rack
  module Logjam
    module Formatters
      class Xml < ::Rack::Logjam::Formatters::Base

        def render
          ::Nokogiri.XML( content ) do |config|
            config.default_xml.noblanks
          end.to_xml( indent: 2 )
        end

      end
    end
  end
end
