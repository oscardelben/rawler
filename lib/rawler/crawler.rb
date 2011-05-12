# `Rawler::Crawler` is responsible for parsing links inside a page

module Rawler
  
  class Crawler
    
    # An instance of Rawler::Crawler has a url which represents the url for which we want to parse links.

    attr_accessor :url

    # We want to skip some kind of formats

    SKIP_FORMATS = /^(javascript|mailto)/
 
    # To use this class, just pass it a url

    def initialize(url)
      @url = url.strip
    end

    # And then call `links` to get its links.
    
    def links
      # If the url is different than the main Rawler.url, or if the page is not html, we return an empty array
      if different_domain?(url, Rawler.url) || not_html?(url)
        return []
      end
      
      # Otherwise we fetch the page

      response = Rawler::Request.get(url)

      # And kindly ask nokogiri to convert it for us
      
      doc = Nokogiri::HTML(response.body)

      # We then do some magic, search all the links in the document that contain a valid link, and return them.
      doc.css('a').map { |a| a['href'] }.select { |url| !url.nil? }.map { |url| absolute_url(url) }.select { |url| valid_url?(url) }
    rescue Errno::ECONNREFUSED
      write("Couldn't connect to #{url}")
      []
    rescue Errno::ETIMEDOUT
      write("Connection to #{url} timed out")
      []
    end
    
    private
    
    # Here's how we transform a relative url to an absolute url

    def absolute_url(path)
      # First, encode the url
      path = URI.encode(path.strip, Regexp.new("[^#{URI::PATTERN::UNRESERVED}#{URI::PATTERN::RESERVED}#]"))

      # if the url contains a scheme that means it's already absolute
      if URI.parse(path).scheme
        path
      else
        # Otherwise we merge `url` to get the absolute url
        URI.parse(url).merge(path).to_s
      end
    rescue URI::InvalidURIError
      write("Invalid url: #{path} - Called from: #{url}")
      nil
    end
    
    # Some helper methods

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
      
      url.strip!
      scheme = URI.parse(url).scheme
      
      if ['http', 'https'].include?(scheme)
        true
      else
        write("Invalid url - #{url}") unless url =~ SKIP_FORMATS
        false
      end

    rescue URI::InvalidURIError
      false
       write("Invalid url - #{url}")
    end
      
  end
  
end
