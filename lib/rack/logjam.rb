module Rack
  module Logjam

    autoload :ANSI,          'rack/logjam/ansi'
    autoload :Configuration, 'rack/logjam/configuration'
    autoload :Filters,       'rack/logjam/filters'
    autoload :Formatters,    'rack/logjam/formatters'
    autoload :Grape,         'rack/logjam/grape'
    autoload :Logger,        'rack/logjam/logger'
    autoload :Rails,         'rack/logjam/rails'
    autoload :VERSION,       'rack/logjam/version'

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.configuration=( configuration )
      @configuration = configuration
    end

    def self.configure
      yield( configuration ) if block_given?
    end

    class << self
      attr_accessor :logger
    end

  end
end

Rack::Logjam::Formatters.register 'application/x-www-form-urlencoded', :FormUrlencoded
Rack::Logjam::Formatters.register 'application/json', :Json
Rack::Logjam::Formatters.register 'text/plain', :TextPlain
Rack::Logjam::Formatters.register 'application/xml', :Xml
