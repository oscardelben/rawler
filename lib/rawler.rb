require 'rubygems'
require 'net/http'
require 'net/https'
require 'nokogiri'

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rawler/core_extensions'

module Rawler
  VERSION = '0.0.2'
  
  mattr_accessor :output
  mattr_accessor :url
  
  mattr_accessor :username, :password
  
  autoload :Base, "rawler/base"
  autoload :Crawler, "rawler/crawler"
  autoload :Request, "rawler/request"
end