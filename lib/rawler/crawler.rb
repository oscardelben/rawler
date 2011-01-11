module Rawler
  
  class Crawler
    
    attr_accessor :url, :links

    def initialize(url)
      @url = url
    end
    
    def links
      uri = URI.parse(url)
      main_uri = URI.parse(Rawler.url)
      
      if uri.host != main_uri.host
        return []
      end
      
      doc = Nokogiri::HTML(fetch_page(uri))
      doc.css('a').map { |a| absolute_url(a['href']) }
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
    
    def fetch_page(uri)
      Net::HTTP.get(uri)
    end
  
  end
  
end