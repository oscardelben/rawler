require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe Rawler::Crawler do

  context "basic functionality" do
    
    let(:url) { 'http://example.com' }
    let(:crawler) { Rawler::Crawler.new(url) }
    let(:content) {
      content = <<-content
        <p><a href="http://example.com/foo">foo</a></p>

    		<p><a href="http://external.com/bar">bar</a></p>
    	content
    }

    before(:each) do
      register(url, content)
    end

    it "should parse all links" do
      crawler.links.should == ['http://example.com/foo', 'http://external.com/bar']
    end
    
  end
  
  context "relative paths" do
    
    let(:url)     { 'http://example.com/path' }
    let(:crawler) { Rawler::Crawler.new(url) }
    let(:content) { '<a href="/foo">foo</a>' }
    
    before(:each) do
      register(url, content)
    end
    
    it "should parse relative links" do
      crawler.links.should == ['http://example.com/foo']
    end
    
  end
  
  context "different domains" do
    
    let(:url)     { 'http://external.com/path' }
    let(:crawler) { Rawler::Crawler.new(url) }
    let(:content) { '<a href="/foo">foo</a>' }
    
    before(:each) do
      register(url, content)
    end
    
    it "should parse relative links" do
      crawler.links.should == []
    end
    
  end
  
end