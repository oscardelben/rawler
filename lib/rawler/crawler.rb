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
      doc.css('a').map { |a| absolute_url(a['href']) }.select { |url| valid_url?(url) }
    rescue Errno::ECONNREFUSED
      write("Couldn't connect to #{url}")
      []
    end
    
    private
    
    def absolute_url(path)
      URI.parse(url).merge(path.to_s).to_s
    end
    
    def write(message)
      Rawler.output.puts(message)
    end
        
    def different_domain?(url_1, url_2)
      URI.parse(url_1).host != URI.parse(url_2).host
    end
    
    def not_html?(url)
      Rawler::Request.head(url).content_type != 'text/html'
    end
    
    def valid_url?(url)
      scheme = URI.parse(url).scheme

      ['http', 'https'].include?(scheme)
    end
  
  end
  
end