# encoding: UTF-8

require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Rawler::Base do

  let(:output)  { double('output').as_null_object }
  let(:rawler)  { Rawler::Base.new('http://example.com', output) }
  
  before(:each) do
    Rawler.stub!(:output).and_return(output)
    register('http://example.com', site)
  end

  describe "url encoding" do
    it "should encode url" do
      original = 'http://example.com/写程序容易出现的几个不好的地方'
      expected = 'http://example.com/%E5%86%99%E7%A8%8B%E5%BA%8F%E5%AE%B9%E6%98%93%E5%87%BA%E7%8E%B0%E7%9A%84%E5%87%A0%E4%B8%AA%E4%B8%8D%E5%A5%BD%E7%9A%84%E5%9C%B0%E6%96%B9'

      Rawler::Base.new(original, output)
      Rawler.url.should == expected
    end
    
    it "should auto prepend http" do
      original = 'example.com'
      expected = 'http://example.com'
      Rawler::Base.new(original, output)
      Rawler.url.should == expected
    end
    
    it "should not auto prepend http when already http" do
      original = 'http://example.com'
      expected = 'http://example.com'
      Rawler::Base.new(original, output)
      Rawler.url.should == expected
    end
    
    it "should not auto prepend http when https" do
      original = 'https://example.com'
      expected = 'https://example.com'
      Rawler::Base.new(original, output)
      Rawler.url.should == expected
    end
  end
  
  describe "validate_links" do
    
    it "should validate links recursively" do
      register('http://example.com/foo1', '<a href="http://external.com/foo">x</a>')
      register('http://example.com/foo2', '')
      register('http://external.com', '')
      register('http://external.com/foo', '')

      rawler.validate
      
      rawler.responses['http://example.com/foo1'].should_not be_nil
      rawler.responses['http://example.com/foo2'].should_not be_nil
      rawler.responses['http://external.com'].should_not be_nil
      rawler.responses['http://external.com/foo'].should_not be_nil
    end
    
    it "should not validate links on external pages" do
      register('http://example.com/foo', '<a href="http://external.com/foo">x</a>')
      register('http://external.com/foo', '<a href="http://external.com/bar">x</a>')
      register('http://external.com/bar', '')
      
      rawler.validate
      
      rawler.responses['http://external.com/foo'].should_not be_nil
      rawler.responses['http://external.com/bar'].should be_nil
    end
    
    it "should output results" do
      register('http://example.com/foo1', '<a href="http://external.com/foo">x</a>')
      register('http://example.com/foo2', '')
      register('http://external.com', '')
      register('http://external.com/foo', '', 301)
      
      output.should_receive(:info).with('200 - http://example.com/foo1')
      output.should_receive(:info).with('200 - http://example.com/foo2')
      output.should_receive(:info).with('200 - http://external.com')
      output.should_receive(:warn).with('301 - http://external.com/foo - Called from: http://example.com/foo1')
      
      rawler.validate
    end

    it "should follow redirections but inform about them" do
      register('http://example.com', '<a href="/foo">foo</a>')
      register('http://example.com/foo', '', 301, :location => 'http://example.com/bar')
      register('http://example.com/bar', '')

      output.should_receive(:warn).with('301 - http://example.com/foo - Called from: http://example.com - Following redirection to: http://example.com/bar')
      output.should_receive(:info).with('200 - http://example.com/bar')

      rawler.validate
    end

    it "should handle circular redirections" do
      register('http://example.com', '<a href="/foo">foo</a>')
      register('http://example.com/foo', '', 301, :location => 'http://example.com/foo')

      output.should_receive(:warn).with('301 - http://example.com/foo - Called from: http://example.com - Following redirection to: http://example.com/foo')

      rawler.validate
    end

  end
  
  describe "get_status_code" do

    it "should add to 200 links" do
      url = 'http://example.com/foo'
      from = 'http://other.com'
      register(url, '', 200)
      
      rawler.send(:add_status_code, url, from)
      
      rawler.responses[url][:status].should == 200
    end
    
    it "should add to 301 links" do
      url = 'http://example.com/foo'
      from = 'http://other.com'
      register(url, '', 301)
      
      rawler.send(:add_status_code, url, from)
      
      rawler.responses[url][:status].should == 301
    end
    
    it "should save username and password" do
      rawler = Rawler::Base.new('http://example.com', output, {:username => 'my_user', :password => 'secret'})
      
      Rawler.username.should == 'my_user'
      Rawler.password.should == 'secret'
    end
    
    it "should save wait" do
      rawler = Rawler::Base.new('http://example.com', output, {:wait => 5})
      
      Rawler.wait.should == 5
    end
    
    it "should rescue from Errno::ECONNREFUSED" do
      url = 'http://example.com'
      from = 'http://other.com'
      
      Rawler::Request.should_receive(:get).and_raise Errno::ECONNREFUSED
      
      output.should_receive(:error).with("Connection refused - #{url} - Called from: #{from}")
      
      rawler.send(:add_status_code, url, from)
    end
    
    [Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, Errno::ETIMEDOUT, EOFError,
    Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, SocketError].each do |error|
       it "should rescue from #{error}" do
         url = 'http://example.com'
         from = 'http://other.com'

         Rawler::Request.should_receive(:get).and_raise error

         output.should_receive(:error).with("Connection problems - #{url} - Called from: #{from}")

         rawler.send(:add_status_code, url, from)
       end   
    end

    it "should rescue from general errors" do
      url = 'http://example.com'
      from = 'http://other.com'
      
      Rawler::Request.should_receive(:get).and_raise
      
      output.should_receive(:error).with("Unknown error - #{url} - Called from: #{from}")
      
      rawler.send(:add_status_code, url, from)
    end

    
  end
  
  describe "record_response" do
    
    let(:link) { 'http://foo.com' }
    let(:from) { 'http://bar.com' }
    
    context "response code 100" do
      %w!100, 150, 199!.each do |code|

        it "logger should receive info" do
          output.should_receive(:info).with("#{code} - #{link}")
          rawler.send(:record_response, code, link, from)
        end
        
      end
    end
    
    context "response code 200" do
      %w!200, 250, 299!.each do |code|

        it "logger should receive info" do
          output.should_receive(:info).with("#{code} - #{link}")
          rawler.send(:record_response, code, link, from)
        end
        
      end
    end
    
    context "response code 300" do
      %w!300, 350, 399!.each do |code|

        it "logger should receive warn" do
          output.should_receive(:warn).with("#{code} - #{link} - Called from: #{from}")
          rawler.send(:record_response, code, link, from)
        end
        
      end
    end
    
    context "response code 400" do
      %w!400, 450, 499!.each do |code|

        it "logger should receive info" do
          output.should_receive(:error).with("#{code} - #{link} - Called from: #{from}")
          rawler.send(:record_response, code, link, from)
        end
        
      end
    end
    
    context "response code 500" do
      %w!400, 550, 599!.each do |code|

        it "logger should receive info" do
          output.should_receive(:error).with("#{code} - #{link} - Called from: #{from}")
          rawler.send(:record_response, code, link, from)
        end
        
      end
    end
    
    context "response code invalid" do
      let(:code) { 600 }
      
      it "logger should receive eror" do
        output.should_receive(:error).with("Unknown code #{code} - #{link} - Called from: #{from}")
        rawler.send(:record_response, code, link, from)
      end
    end
    
  end
  
  
  private
  
  def site
    <<-site
      <html>
        <body>
          <a href="http://example.com/foo1">foo1</a>
          <a href="http://example.com/foo2">foo2</a>

          <a href="http://external.com">external</a>
        </body>
      </html>
    site
  end
  
end
