# **Rawler** is a command line tool for finding broken links on your website.
# You can install Rawler by running:
#
#   gem install rawler
#
# To use Rawler type:
#
#   rawler example.com
# 
# Type `rawler -h` to see all the available options (including basic auth support).

#### Prerequisites


require 'rubygems'

# We use [net/https](http://www.ruby-doc.org/stdlib/libdoc/net/http/rdoc/index.html) for making requests.

require 'net/https'

# We use [nokogiri](http://nokogiri.org/) for parsing web pages.

require 'nokogiri'

# We use the [logger](http://www.ruby-doc.org/stdlib/libdoc/logger/rdoc/) utility for handling the output.

require 'logger'

# We require [rawler/core_extensions](rawler/core_extensions.html) which includes some core extensions we need.

require 'rawler/core_extensions'

#### The Rawler module

# The Rawler module itself is very simple, and it's only used for storing configuration data like the url that we want to fetch, basic username and password.

module Rawler
  VERSION = '0.1.1'
  
  # `output` is where we want to direct output. It's set to `$stdout` by default.

  mattr_accessor :output

  # `url` is the url that we want to fetch. We need to keep track of it when parsing other pages to see if they are of the same domain.

  mattr_accessor :url

  # The time we wait between requests, default 3. We don't want to send too many requests to your website!

  mattr_accessor :wait
  
  # Username and Password for basic auth, if needed.

  mattr_accessor :username, :password
  
  # Here we autoload when needed the specific namespaces.

  # [Rawler::Base](rawler/base.html) is responsible for validating all the pages in a domain. It's where all the magic happens.

  autoload :Base, "rawler/base"

  # [Rawler::Crawler](rawler/crawler.html) is responsible for parsing links inside a page.

  autoload :Crawler, "rawler/crawler"

  # [Rawler::Request](rawler/reqeust.html) contains some helper methods for performing requests.

  autoload :Request, "rawler/request"

  # We overwrite url= to automatically add `http://` if needed so that you can simply type `rawler example.com` in the command line.

  def self.url=(url)
    url.strip!

    if (url =~ /http:\/\//) != 0
      url = 'http://' + url
    end

    @@url = url
  end
end
