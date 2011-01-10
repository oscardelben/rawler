module Rawler
  
  class Crawler
    
    attr_accessor :url, :links

    def initialize(url)
      @url = url
    end
    
    def links
      content = Net::HTTP.get(URI.parse(url))
      
      doc = Nokogiri::HTML(content)
      doc.css('a').map { |a| a['href'] }
    rescue Errno::ECONNREFUSED
      $output.puts "Couldn't connect to #{url}"
      []
    end
  
  end
  
end