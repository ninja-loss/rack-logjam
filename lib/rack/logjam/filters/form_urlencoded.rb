require 'jsonpath'

module Rack
  module Logjam
    module Filters
      class FormUrlencoded < Rack::Logjam::Filters::Base

        def render
          return content if blank_content?
          apply_filters
          query_hash.to_query
        end

      protected

        def blank_content?
          content.nil? || content.strip.empty?
        end

        def apply_filters
          filters.each do |param, action, length|
            if value = query_hash[param]
              if value.is_a?(Array)
                query_hash[param] = value.map { |array_item| filter(array_item, action, length) }
              else
                query_hash[param] = filter(value, action, length)
              end
            end
          end
        end

        def filter(value, action, length)
          method_name = "#{action}_#{value.class.name.downcase}"
          if respond_to?( method_name, true )
            send( method_name, value, length )
          else
            "[#{action.upcase}ED: #{value.class.name}]"
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

        def query_hash
          # This gives a weird response where every value is an array, even when there's no key
          # @query_hash ||= CGI.parse(content)

          @query_hash ||= Rack::Utils.parse_nested_query(content)
        end

      end
    end
  end
end
