
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'rawler'
require 'fakeweb'

FakeWeb.allow_net_connect = false

def register(uri, content, status=200)
  FakeWeb.register_uri(:any, uri, :body => content, :status => status)
end