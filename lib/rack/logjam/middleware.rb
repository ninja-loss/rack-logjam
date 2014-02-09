module Rack; module Logjam; class Middleware

  def initialize( app )
    @app = app
  end

  def call( env )
    before env
    app.call( env ).tap do |rack_response|
      after env, *rack_response
    end
  end

protected

  attr_reader :app

  def before( env )
    return unless api_request?( env )

    Rails.logger.info <<-end_info
[#{ANSI.green { 'api' }}] #{ANSI.cyan { '--- Request Env ---' }}
#{ANSI.magenta { JSON.pretty_generate( request_log_data( env )) }}
[#{ANSI.green { 'api' }}] #{ANSI.cyan { '--- Request Body ---' }}
#{ANSI.cyan { formatted_request_body( env ) }}
    end_info
  end

  def after( env, status, headers, response )
    return unless api_request?( env )

    Rails.logger.info <<-end_info
[#{ANSI.green { 'api' }}] #{ANSI.cyan { '--- Response ---' }}
Status: #{status}
Headers: #{headers.inspect}
Body:
#{ANSI.cyan { format_body( response.body, accept( env ), env ) }}
    end_info
  end

  def request_log_data( env )
    request_data = {
      auth_token:     env['HTTP_X_NCITE_AUTH_TOKEN'],
      content_type:   content_type( env ),
      content_length: env['CONTENT_LENGTH'],
      accept:         accept( env ),
      accept_version: env['HTTP_ACCEPT_VERSION'],
      method:         env['REQUEST_METHOD'],
      path:           path_info( env ),
      query:          query( env )
    }
    #request_data[:user_id] = current_user.id if current_user
    request_data
  end

  def api_request?( env )
    path_info( env ) =~ /^\/api\//
  end

  def content_type( env )
    env['CONTENT_TYPE']
  end

  def accept( env )
    env['HTTP_ACCEPT']
  end

  def path_info( env )
    env['PATH_INFO']
  end

  def query( env )
    URI.unescape( env['QUERY_STRING'] )
  end

  def formatted_request_body( env )
    format_body( rack_input_content( env ), content_type( env ), env )
  end

  def format_body( body, format, env )
    return body if body.strip.nil? || body.strip.empty?

    if format == Mime::JSON.to_s
      hash = truncate_json_attributes( body )
      return JSON.pretty_generate( hash )
    elsif format == Mime::XML.to_s
      return Nokogiri.XML( body ) do |config|
        config.default_xml.noblanks
      end.to_xml( indent: 2 )
    elsif format == Mime::URL_ENCODED_FORM.to_s
      return URI.unescape( body )
    elsif format == Mime::OCTET_STREAM.to_s
      return "no body b/c content type is #{Mime::OCTET_STREAM}"
    end

    body
  end

  def rack_input_content( env )
    ( rack_input = env['rack.input'] ).read.tap do |content|
      rack_input.rewind
    end
  end

  # Can currently use the following xpath expressions that will translate to json_path:
  # /some/path -> $.some.path (search from root)
  # some/path -> some.path (search for any sub-path that matches this, not bound to root)
  # //path -> $..path (recursive search)
  #
  def truncated_attributes_as_xpath
    %w(
      //image_as_base64
      //fingerprint_image_as_base64
    )
  end

  def truncate_json_attributes( json )
    json_path = JsonPath.for( json )
    truncated_attributes_as_json_paths.each do |j_path|
      json_path.gsub!( j_path ) { |val| (val.nil? || val.empty?) ? val : "#{val[0..25]} ... [TRUNCATED] ..." }
    end
    json_path.to_hash
  end

  def truncated_attributes_as_json_paths
    truncated_attributes_as_xpath.map do |xpath|
      if xpath.start_with?( '//' )
        xpath.gsub( '//', '$..' )
      else
        parts = xpath.split( '/' )
        parts[0] = '$' if parts[0] == ''
        parts.join( '.' )
      end
    end
  end

end; end; end
