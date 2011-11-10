# `Rawler::Request` contains some abstraction for making web requests, like automatically adding ssl and basic auth.

module Rawler
  
  class Request
   
    class << self
      
      def get(url)
        perform_request(:get, url)
      end
      
      def head(url)
        perform_request(:head, url)
      end
      
      private
      
      def perform_request(method, url)
        uri = URI.parse(url)

        # Use http_proxy if set
        proxy = URI.parse(ENV['http_proxy']) if ENV['http_proxy'] rescue nil
        if proxy
          http = Net::HTTP::Proxy(proxy.host, proxy.port).new(uri.host, uri.port)
        else
          http = Net::HTTP.new(uri.host, uri.port)
        end
        http.use_ssl = (uri.scheme == 'https')
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        
        path = (uri.path.size == 0)  ? "/" : uri.path
        
        request = Net::HTTP::Get.new(path)
        request.basic_auth(Rawler.username, Rawler.password)
        http.request(request)
      end
      
    end
    
  end
  
end
