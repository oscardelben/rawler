module Rawler
  class Crawler

    attr_accessor :url

    SKIP_FORMATS = /^(javascript|mailto|callto)/

    def initialize(url)
      @url = url.strip
    end

    def links
      if different_domain?(url, Rawler.url) || not_html?(url)
        return []
      end

      response = Rawler::Request.get(url)

      doc = Nokogiri::HTML(response.body)

      doc.css('a').map { |a| a['href'] }.select { |url| !url.nil? }.map { |url| absolute_url(url) }.select { |url| valid_url?(url) }
    rescue Errno::ECONNREFUSED
      write("Couldn't connect to #{url}")
      []
    rescue Errno::ETIMEDOUT
      write("Connection to #{url} timed out")
      []
    end

    def css_links
      if different_domain?(url, Rawler.url) || not_html?(url)
        return []
      end

      response = Rawler::Request.get(url)

      doc = Nokogiri::HTML(response.body)

      doc.css('link').map { |a| a['href'] }.select { |url| !url.nil? }.map { |url| absolute_url(url) }.select { |url| valid_url?(url) }
    rescue Errno::ECONNREFUSED
      write("Couldn't connect to #{url}")
      []
    rescue Errno::ETIMEDOUT
      write("Connection to #{url} timed out")
      []
    end

    private

    def absolute_url(path)
      path = URI.encode(path.strip, Regexp.new("[^#{URI::PATTERN::UNRESERVED}#{URI::PATTERN::RESERVED}#]"))

      if URI.parse(path).scheme
        path
      else
        URI.parse(url).merge(path).to_s
      end
    rescue URI::InvalidURIError, URI::InvalidComponentError
      write("Invalid url: #{path} - Called from: #{url}")
      nil
    end

    def write(message)
      Rawler.output.error(message)
    end

    def different_domain?(url_1, url_2)
      URI.parse(url_1).host != URI.parse(url_2).host
    end

    def content_type(url)
      Rawler::Request.head(url).content_type
    end

    def not_html?(url)
      content_type(url) != 'text/html'
    end

    def not_css?(url)
       content_type(url) != 'text/css'
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
