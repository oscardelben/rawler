module Rawler
  class Base

    attr_accessor :responses

    def initialize(url, output, options={})
      @responses = {}

      Rawler.url      = URI.escape(url)
      output.sync     = true
      Rawler.output   = Logger.new(output)
      Rawler.username = options[:username]
      Rawler.password = options[:password]
      Rawler.wait     = options[:wait]
      Rawler.log      = options[:log]
      Rawler.css      = options[:css]
      @logfile = File.new("rawler_log.txt", "w") if Rawler.log
    end

    def validate
      validate_links_in_page(Rawler.url)
      @logfile.close if Rawler.log
    end

    private

    def validate_links_in_page(page)
      Rawler::Crawler.new(page).links.each do |page_url|
        validate_page(page_url, page)
        sleep(Rawler.wait)
      end
    end

    def validate_css_links_in_page(page)
      Rawler::Crawler.new(page).css_links.each do |page_url|
        validate_non_html(page_url, page)
        sleep(Rawler.wait)
      end
    end

    def validate_page(page_url, from_url)
      if not_yet_parsed?(page_url)
        add_status_code(page_url, from_url) 
        validate_links_in_page(page_url) if same_domain?(page_url)
        validate_css_links_in_page(page_url) if same_domain?(page_url) and Rawler.css
      end
    end

    def validate_non_html(page_url, from_url)
      if not_yet_parsed?(page_url)  
        add_status_code(page_url, from_url)
      end
    end

    def add_status_code(link, from_url)
      response = Rawler::Request.get(link)

      record_response(response.code, link, from_url, response['Location'])
      responses[link] = { :status => response.code.to_i }

      validate_page(response['Location'], from_url) if response['Location']

    rescue Errno::ECONNREFUSED
      error("Connection refused - #{link} - Called from: #{from_url}")
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, Errno::ETIMEDOUT,
      EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, SocketError
      error("Connection problems - #{link} - Called from: #{from_url}")
    rescue Exception
      error("Unknown error - #{link} - Called from: #{from_url}")
    end

    def same_domain?(link)
      URI.parse(Rawler.url).host == URI.parse(link).host
    end

    def not_yet_parsed?(link)
      responses[link].nil?
    end

    def error(message)
      Rawler.output.error(message)
    end

    def record_response(code, link, from_url, redirection=nil)
      message = "#{code} - #{link}"

      if code.to_i >= 300
        message += " - Called from: #{from_url}"
      end

      message += " - Following redirection to: #{redirection}" if redirection

      code = code.to_i
      case code / 100
      when 1,2
        Rawler.output.info(message)
      when 3 then
        Rawler.output.warn(message)
      when 4,5 then
        Rawler.output.error(message)
      else
        Rawler.output.error("Unknown code #{message}")
      end
      @logfile.puts(message) if Rawler.log
    end
  end
end
