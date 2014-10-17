require 'jsonpath'

module Rack
  module Logjam
    module Filters
      class Json < Rack::Logjam::Filters::Base

        def render
          apply_filters
          json_path.to_json
        end

      protected

        def apply_filters
          filters.each do |j_path, action, length|
            json_path.gsub!( j_path ) do |val|
              method_name = "#{action}_#{val.class.name.downcase}"
              if respond_to?( method_name, true )
                send( method_name, val, length )
              else
                "[#{action.upcase}ED: #{val.class.name}]"
              end
            end
          end
        end

        def redact_nilclass( val, *args )
          nil
        end

        def truncate_nilclass( val, length )
          nil
        end

        def redact_string( val, *args )
          (val.nil? || val.empty?) ?
            val :
            "[REDACTED]"
        end

        def truncate_string( val, length )
          (val.nil? || val.empty?) ?
            val :
            "#{val[0..length]}...[TRUNCATED]..."
        end

        def json_path
          @json_path ||= ::JsonPath.for( content )
        end

      end
    end
  end
end
