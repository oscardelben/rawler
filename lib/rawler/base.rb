module Rawler
  
  class Base
    
    attr_accessor :responses
    
    def initialize(url, output, username=nil, password=nil)
      @responses = {}

      Rawler.url      = url
      Rawler.output   = Logger.new(output)
      Rawler.username = username
      Rawler.password = password
    end
    
    def validate
      validate_links_in_page(Rawler.url)
    end
    
    private
    
    def validate_links_in_page(current_url)
      Rawler::Crawler.new(current_url).links.each do |page_url|
        validate_page(page_url)
        # Todo: include this in a configuration option
        sleep(3)
      end
    end
    
    def validate_page(page_url)
      if not_yet_parsed?(page_url)
        add_status_code(page_url) 
        validate_links_in_page(page_url) if same_domain?(page_url)
      end
    end
    
    def add_status_code(link)
      response = Rawler::Request.get(link)
      
      record_response(response.code, link)
      responses[link] = { :status => response.code.to_i }
    rescue Errno::ECONNREFUSED
      Rawler.output.error("Connection refused - '#{link}'")
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, Errno::ETIMEDOUT,
      EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
      Rawler.output.error("Connection problems - '#{link}'")
    end
    
    def same_domain?(link)
      URI.parse(Rawler.url).host == URI.parse(link).host
    end
    
    def not_yet_parsed?(link)
      responses[link].nil?
    end
    
    def write(message)
      # TODO: This may not always be an error message, 
      # but that will make it show up most of the time
      Rawler.output.error(message)
    end
    
    def record_response(code, link)
      message = "#{code} - #{link}"
      code = code.to_i
      case code / 100
      when 1
        # TODO: check that if a 100 is received
        # then there is another status code as well
        Rawler.output.info(message)
      when 2:
        Rawler.output.info(message)
      when 3:
        Rawler.output.warn(message)
      when 4,5
        Rawler.output.error(message)
      else
        Rawler.output.error("Unknown code #{message}")
      end
    end
    
  end
  
end