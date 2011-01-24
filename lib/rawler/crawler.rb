module Rawler
  
  class Crawler
    
    attr_accessor :url, :links

    def initialize(url)
      @url = url
    end
    
    def links
      if different_domain?(url, Rawler.url) || not_html?(url)
        return []
      end
      
      response = Rawler::Request.get(url)
      
      doc = Nokogiri::HTML(response.body)
      doc.css('a').map { |a| a['href'] }.map { |url| absolute_url(url) }.select { |url| valid_url?(url) }
    rescue Errno::ECONNREFUSED
      write("Couldn't connect to #{url}")
      []
    rescue Errno::ETIMEDOUT
      write("Connection to #{url} timed out")
      []
    end
    
    private
    
    def absolute_url(path)
      if path[0].chr == '/'
        URI.parse(url).merge(path.to_s).to_s
      else
        path
      end
    end
    
    def write(message)
      Rawler.output.error(message)
    end
        
    def different_domain?(url_1, url_2)
      URI.parse(url_1).host != URI.parse(url_2).host
    end
    
    def not_html?(url)
      Rawler::Request.head(url).content_type != 'text/html'
    end
    
    def valid_url?(url)
      return false unless url
      
      scheme = URI.parse(url).scheme
      
      if ['http', 'https'].include?(scheme)
        true
      else
        write("Invalid url - #{url}")
        false
      end
    end
      
  end
  
end