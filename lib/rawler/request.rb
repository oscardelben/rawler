module Rawler
  
  class Request
   
    class << self
      
      def get(url)
        uri = URI.parse(url)
        
        response = nil

        Net::HTTP.start(uri.host, uri.port) do |http|
          path = (uri.path.size == 0)  ? "/" : uri.path
          response = http.get(path, {'User-Agent'=>'Rawler'})
        end
        
        response
      end
      
      def head(url)
        uri = URI.parse(url)
        
        response = nil

        Net::HTTP.start(uri.host, uri.port) do |http|
          path = (uri.path.size == 0)  ? "/" : uri.path
          response = http.head(path, {'User-Agent'=>'Rawler'})
        end
        
        response
      end
      
    end
    
  end
  
end