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
  mattr_accessor :log
  mattr_accessor :css

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
end
