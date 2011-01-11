module Rawler
  
  class Crawler
    
    attr_accessor :url, :links

    def initialize(url)
      @url = url
    end
    
    def links
      content = Net::HTTP.get(URI.parse(url))
      
      doc = Nokogiri::HTML(content)
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
  
  end
  
end