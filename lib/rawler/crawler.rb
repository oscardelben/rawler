module Rawler
  
  class Crawler
    
    attr_accessor :url, :links

    def initialize(url)
      @url = url
    end
    
    def links
      uri = URI.parse(url)
      main_uri = URI.parse(Rawler.url)
      
      if different_domain?(uri, main_uri) || not_html?(uri)
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
    
    def different_domain?(uri_1, uri_2)
      uri_1.host != uri_2.host
    end
    
    def not_html?(uri)
      response = nil

      Net::HTTP.start(uri.host, uri.port) do |http|
        path = (uri.path.size == 0)  ? "/" : uri.path
        response = http.head(path, {'User-Agent'=>'Rawler'})
      end

      response.content_type != 'text/html'
    end
  
  end
  
end