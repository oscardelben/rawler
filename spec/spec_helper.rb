module Kernel

  def sleep(duration)
    nil
  end

end


$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'rawler'
require 'fakeweb'

FakeWeb.allow_net_connect = false

def register(uri, content, status=200, options={})
  FakeWeb.register_uri(:any, uri, { :body => content, :status => status, :content_type => 'text/html' }.merge(options))
end

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end
