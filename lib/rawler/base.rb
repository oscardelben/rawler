module Rawler
  
  class Base
    
    attr_accessor :responses
    
    def initialize(url, output, username=nil, password=nil)
      @responses = {}

      Rawler.url      = url
      Rawler.output   = output
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
      
      write("#{response.code} - #{link}")
      responses[link] = { :status => response.code.to_i }
    rescue Errno::ECONNREFUSED
      write("Connection refused - '#{link}'")
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
           Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
      write("Connection problems - '#{link}'")
    end
    
    def same_domain?(link)
      URI.parse(URI.encode(Rawler.url)).host == URI.parse(URI.encode(link)).host
    end
    
    def not_yet_parsed?(link)
      responses[link].nil?
    end
    
    def write(message)
      Rawler.output.puts(message)
    end
    
  end
  
end