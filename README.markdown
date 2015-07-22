# Rack::Logjam

Logs helpful HTTP information on Rack requests.


## Installation

Add this line to your application's Gemfile:

    gem 'rack-logjam'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-logjam


## Usage

### Including the Middleware

#### Grape

Include the middleware in your API classes with the `use` statement

    module AwesomeApp
      class ApiV1 < Grape::API
        use Rack::Logjam::Grape::Middleware
      end
    end


#### Rails

Require the middleware in `config/application.rb`

    config.middleware.use( 'Rack::Logjam::Rails::Middleware' )

### Configuration

At a minimum one must specify the logger that rack-logjam will use.

    Rack::Logjam.configure |c|
      c.logger = Rails.logger
    end

#### Formatters

Rack::Logjam includes several default formatters that are registered by default: `Array, FormUrlencoded, Json, TextPlain, and Xml`.  Formatters 
are registered and selected by mime-types.  If a the mime-type of a response does not have a regostered formatter, it will output a message to
the log in place of the body specifying the lack of formatter and mime-type.

Additionally, you can configure custom mime-types with formatters in the configuration file.

    Rack::Logjam.configure |c|
      # register custom mime-types with inlcuded formatters
      c.register_formatter 'application/vnd.awesome-app-v1+x-www-form-urlencoded', :FormUrlencoded
      c.register_formatter 'application/vnd.awesome-app-v1+json', :Json                        
      c.register_formatter 'application/vnd.awesome-app-v1+text', :TextPlain                        
      c.register_formatter 'application/vnd.awesome-app-v1+xml', :Xml

      # register custom mime-type with custom formatter
      c.register_formatter 'application/vnd.awesome-app-v1+csv', AwesomeApp::LogFormatter::Csv 
    end

#### Filters

Filters can fully fully redact or truncate data within data structures.  Filters are registered and selected by mime-types.  No filters are 
registered by default.  However, Rack::Logjam includes a `Json` filter.  The Json filter uses [JsonPath](https://github.com/joshbuddy/jsonpath)
to specify which attributes are filtered.

Additionally, you can configure custom mime-types with filters in the configuration file.

    Rack::Logjam.configure |c|
      # configure a mime-type with the built in Json filter
      #   this filter will truncate all image_as_base64 attributes 
      #   at any level of nesting and redact the subject/date_of_birth
      c.register_filter 'application/vnd.ncite-vetting-v1+json', :Json, [
        ['$..image_as_base64', :truncate, 10],
        ['$.subject_attributes.date_of_birth', :redact]
      ]
    end

#### Custom Formatters and Filters

##### Writing a Custom Formatter

A formatter is a simply a class that accepts content in an initializer and implements a #render method with no parameters.  Folowing
is an implementation of a CSV formatter.

    module AwesomeApp
      module Formatter
        class Csv
          def initialize( content )
            @content = content
          end

          def render
            content
          end

        protected

          attr_reader :content
        end
      end
    end

The formatter must also be registered with a mime-type.

    c.register_formatter 'application/vnd.awesome-app-v1+csv', AwesomeApp::Formatter::Csv

##### Writing a Custom Filter

A filter is a simply a class that accepts content and filters in an initializer and implements a #render method with no parameters.  Folowing
is a naive implementation of a CSV filter.

    require 'csv' 

    module AwesomeApp
      module Filters
        class Csv
          def initialize( content, filters )
            @content = content
            @filters = filters
          end

          def render
            CSV.parse("some long bit of text",data,123-45-6789,data") do |row|
              filters.each do |column, action, length| 
                row[column] = send( action, row[column], length )
              end
            end
          end

        protected

          def redact( val, *args )
            (val.nil? || val.empty?) ?
              val :
              "[REDACTED]"
          end

          def truncate( val, length )
            (val.nil? || val.empty?) ?
              val :
              "#{val[0..length]}...[TRUNCATED]..."
          end

          attr_reader :content,
                      :filters
        end
      end
    end

The filter must also be registered with a mime-type.

    c.register_filter 'application/vnd.awesome-app-v1+xml', AwesomeApp::Filters::Csv, [
      [0, :truncate, 10],
      [2, :redact]
    ]
