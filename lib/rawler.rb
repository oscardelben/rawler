require 'rubygems'
require 'net/http'
require 'nokogiri'

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rawler/core_extensions'

module Rawler
  VERSION = '0.0.2'
  
  mattr_accessor :output
  
  autoload :Base, "rawler/base"
  autoload :Crawler, "rawler/crawler"
end