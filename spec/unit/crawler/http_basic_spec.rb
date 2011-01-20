require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe Rawler::Crawler do
  
  context "http basic" do
    
    let(:url)     { 'http://example.com' }
    let(:content) { '<a href="http://example.com/secret-path">foo</a>' }
    let(:crawler) { Rawler::Crawler.new('http://example.com/secret') }
    
    before(:each) do
      register('http://example.com/secret', '', :status => ["401", "Unauthorized"])
      register('http://foo:bar@example.com/secret', content)

      Rawler.stub!(:username).and_return('foo')
      Rawler.stub!(:password).and_return('bar')
    end
   
    it "should crawl http basic pages" do
      crawler.links.should == ['http://example.com/secret-path']
    end
    
  end
  
end