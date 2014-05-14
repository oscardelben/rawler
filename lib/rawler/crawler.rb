module Rawler
  class Crawler

    attr_accessor :url

    SKIP_FORMATS = /^(javascript|mailto|callto):/

    def initialize(url)
      @url = url.strip
    end

    def links
      get_links('a')
    end

    def css_links
      get_links('link')
    end

    private

    def get_links(selector)
      links = nil

      unless different_domain?(url, Rawler.url) || not_html?(url)
        # fetch the document
        begin
          response = Rawler::Request.get(url)
        rescue Errno::ECONNREFUSED
          write("Couldn't connect to #{url}")
        rescue Errno::ETIMEDOUT
          write("Connection to #{url} timed out")
        else
          # parse the document
          doc = Nokogiri::HTML(response.body)
          links = doc.css(selector).map { |a| a['href'] }.select { |url| !url.nil? }.map { |url| absolute_url(url) }.select { |url| valid_url?(url) }
        end
      end

      links || []
    end

    def absolute_url(path)
      path = URI.encode(path.strip, Regexp.new("[^#{URI::PATTERN::UNRESERVED}#{URI::PATTERN::RESERVED}#]"))

      uri = URI.parse(path)

      if uri.fragment && Rawler.ignore_fragments
        uri.fragment = nil
      end

      if uri.scheme
        uri.to_s
      else
        URI.parse(url).merge(uri).to_s
      end
    rescue URI::InvalidURIError, URI::InvalidComponentError
      write("Invalid url: #{path} - Called from: #{url}")
      nil
    end

    def write(message)
      Rawler.output.error(message)
    end

    def info(message)
      Rawler.output.info(message)
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
      url = url.to_s.strip
      is_valid = false

      unless url.empty? || url =~ SKIP_FORMATS
        begin
          if url =~ Rawler.skip_url_pattern
            # skipped
          elsif Rawler.include_url_pattern && url !~ Rawler.include_url_pattern
            # not included
          elsif ['http', 'https'].include?(URI.parse(url).scheme)
            is_valid = true
          else
            write("Invalid url - #{url}")
          end
        rescue URI::InvalidURIError
          write("Invalid url - #{url}")
        end
      end

      is_valid
    end
  end
end
