require 'rubygems'
require 'net/http'
require 'nokogiri'

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module Rawler
  VERSION = '0.0.1'
  
  autoload :Base, "rawler/base"
  autoload :Crawler, "rawler/crawler"
end