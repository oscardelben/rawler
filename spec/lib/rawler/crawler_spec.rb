require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe Rawler::Crawler do

  let(:url)    { 'http://example.com' }
  let(:output) { double("output", :error => nil) }

  before(:each) do
    Rawler.stub!(:url).and_return(url)
    Rawler.stub!(:output).and_return(output)
  end

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
      Rawler.stub!(:url).and_return('http://example.com')
      register(url, content)
    end
    
    it "should parse relative links" do
      crawler.links.should == []
    end
    
  end
  
  context "urls with hash tags" do
    
    let(:url)     { 'http://example.com/path' }
    let(:crawler) { Rawler::Crawler.new(url) }
    let(:content) { '<a href="/foo#bar">foo</a>' }
    
    before(:each) do
      register(url, content)
    end
    
    it "should parse relative links" do
      crawler.links.should == ['http://example.com/foo#bar']
    end
    
  end
  
  context "invalid urls" do
    let(:url)     { 'http://example.com/path' }
    let(:crawler) { Rawler::Crawler.new(url) }
    let(:content) { '<a href="invalid">foo</a>' }
    
    before(:each) do
      register(url, content)
    end
    
    it "should parse relative links" do
      crawler.links.should == []
    end
    
    it "should report the error" do
      crawler.should_receive(:write).with("Invalid url - invalid")
      crawler.links
    end
  end
  
  
  context "content type" do
      
    ['text/plain', 'text/css', 'image/jpeg'].each do |content_type|
    
      let(:url)     { 'http://example.com' }
      let(:crawler) { Rawler::Crawler.new(url) }
    
      before(:each) do
        register(url, '', 200, :content_type => content_type)
      end
    
      it "should ignore '#{content_type}'" do
        crawler.links.should == []
      end
  
    end
  end
  
  context "Exceptions" do
    
    let(:url)     { 'http://example.com' }
    let(:crawler) { Rawler::Crawler.new(url) }
    let(:output)  { double('output', :error => nil) }
    
    before(:each) do
      register(url, '')
      Rawler.stub!(:output).and_return(output)
    end
    
    context "Errno::ECONNREFUSED" do
      
      before(:each) do
        Rawler::Request.stub!(:get).and_raise Errno::ECONNREFUSED
      end
      
      it "should return an empty array" do
        crawler.links.should == []
      end

      it "should print a message when raising Errno::ECONNREFUSED" do
        output.should_receive(:error).with("Couldn't connect to #{url}")

        crawler.links
      end      
   
    end
    
    context "Errno::ETIMEDOUT" do
      
      before(:each) do
        Rawler::Request.stub!(:get).and_raise Errno::ETIMEDOUT
      end

      it "should return an empty array when raising Errno::ETIMEDOUT" do
        crawler.links.should == []
      end

      it "should print a message when raising Errno::ETIMEDOUT" do
        output.should_receive(:error).with("Connection to #{url} timed out")

        crawler.links
      end
  
    end
    
  end
  
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
  
  context "url domain" do
    
    let(:content) {
      content = <<-content
        <a href="http://example.com/valid">foo</a>
        <a href="mailto:info@example.com">invalid</a>
        <a href="https://foo.com">valid</a>
        <a href=" http://fooo.com ">valid with illegal whitespaces</a>
      content
    }
    let(:url)     { 'http://example.com' }
    let(:crawler) { Rawler::Crawler.new(url) }
    
    before(:each) do
      register(url, content)
    end
  
    it "should ignore links other than http or https" do
      crawler.links.should == ['http://example.com/valid', 'https://foo.com', 'http://fooo.com']
    end
  end
  
end
