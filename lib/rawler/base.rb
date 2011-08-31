#### Rawler workflow

# `Rawler::Base` is where all the heavy work is being made.
# When you call `rawler somesite.com`, we create an instance of Rawler::Base and then call `validate`, which recursively validates all the links relative to the domain that we specified.

module Rawler
  
  class Base
    
    # `responses` is used to keep track of which links we have already parsed, so that we wont parse them again and again.
    # TODO: rename `responses` to something more meaningful.

    attr_accessor :responses
    
    # When we instantiate `Rawler::Base` we set some options according to what you specified on the command line.

    def initialize(url, output, options={})
      @responses = {}

      Rawler.url      = URI.escape(url)
      output.sync     = true
      Rawler.output   = Logger.new(output)
      Rawler.username = options[:username]
      Rawler.password = options[:password]
      Rawler.wait     = options[:wait].to_i
    end
    
    # The method used to start the real validation process

    def validate
      validate_links_in_page(Rawler.url)
    end
    
    private
    
    # We ask [Rawler::Crawler](crawler.html) for all the links in page and then validate each of them individually.
    # We then sleep for the value of `Rawler.wait` (default 3) between each request to avoid dossing your server.

    def validate_links_in_page(page)
      Rawler::Crawler.new(page).links.each do |page_url|
        validate_page(page_url, page)
        sleep(Rawler.wait)
      end
    end
    
    # If we haven't validated the page yet, we check its status code and then validate all the links in the page if it's in the same domain

    def validate_page(page_url, from_url)
      if not_yet_parsed?(page_url)
        add_status_code(page_url, from_url) 
        validate_links_in_page(page_url) if same_domain?(page_url)
      end
    end
    
    # This is where we check the specific page status.

    def add_status_code(link, from_url)
      response = Rawler::Request.get(link)

      # We follow a redirect if necessary.

      validate_page(response['Location'], from_url) if response['Location']
      
      # We inform the user about what we got.

      record_response(response.code, link, from_url, response['Location'])

      # We add the current page to `responses` to avoid parsing it again/

      responses[link] = { :status => response.code.to_i }
    rescue Errno::ECONNREFUSED
      error("Connection refused - #{link} - Called from: #{from_url}")
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, Errno::ETIMEDOUT,
      EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, SocketError
      error("Connection problems - #{link} - Called from: #{from_url}")
    rescue Exception
      error("Unknown error - #{link} - Called from: #{from_url}")
    end
    
    # Some helper methods

    def same_domain?(link)
      URI.parse(Rawler.url).host == URI.parse(link).host
    end
    
    def not_yet_parsed?(link)
      responses[link].nil?
    end
    
    def error(message)
      Rawler.output.error(message)
    end

    # We use this method to inform the user of a page status
    
    def record_response(code, link, from_url, redirection=nil)

      # By default, we just give the status code and the page url

      message = "#{code} - #{link}"

      # If the status code is more or equal than 300, we also add which url linked the current page

      if code.to_i >= 300
        message += " - Called from: #{from_url}"
      end

      # We add information about redirects, if a redirect was set
          
      message += " - Following redirection to: #{redirection}" if redirection

      # Depending on the status code, we use a different method of logger.

      code = code.to_i
      case code / 100
      when 1
        Rawler.output.info(message)
      when 2 then
        Rawler.output.info(message)
      when 3 then
        Rawler.output.warn(message)
      when 4,5 then
        Rawler.output.error(message)
      else
        Rawler.output.error("Unknown code #{message}")
      end
    end
    
  end
  
end
