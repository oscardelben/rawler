require 'rubygems'
require 'net/https'
require 'nokogiri'
require 'logger'
require 'rawler/core_extensions'
module Rawler
  VERSION = "#{File.read(File.expand_path(File.dirname(__FILE__)) + '/../VERSION')}"

  mattr_accessor :output
  mattr_accessor :url
  mattr_accessor :wait
  mattr_accessor :username, :password
  mattr_accessor :log, :logfile
  mattr_accessor :css
  mattr_accessor :include_url_pattern
  mattr_accessor :skip_url_pattern

  autoload :Base, "rawler/base"
  autoload :Crawler, "rawler/crawler"
  autoload :Request, "rawler/request"

  def self.url=(url)
    url.strip!

    if (url =~ /http[s]?:\/\//) != 0
      url = 'http://' + url
    end

    @@url = url
  end

  def self.create_regex(pattern, icase=false)
    pattern.nil? ? nil : Regexp.new(pattern, icase ? Regexp::IGNORECASE : nil )
  end

  def self.set_include_pattern(pattern, icase=false)
    self.include_url_pattern = self.create_regex(pattern, icase)
  end

  def self.set_skip_pattern(pattern, icase=false)
    self.skip_url_pattern = self.create_regex(pattern, icase)
  end

  def self.local=(is_local)
    pattern = is_local ? "^#{self.url}" : nil
    self.set_include_pattern(pattern)
  end
end
