require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Rawler::Base do

  let(:output)  { double('output').as_null_object }
  let(:rawler)  { Rawler::Base.new('http://example.com', output) }
  
  before(:each) do
    register('http://example.com', site)
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
      register('http://external.com/foo', '', 302)
      
      output.should_receive(:puts).with('200 - http://example.com/foo1')
      output.should_receive(:puts).with('200 - http://example.com/foo2')
      output.should_receive(:puts).with('200 - http://external.com')
      output.should_receive(:puts).with('302 - http://external.com/foo')
      
      rawler.validate
    end
    
    it "should validate links with #hashtags" do
      register('http://example.com/foo1', '<a href="http://example.com/page-with#hashtag">x</a>')
      register('http://example.com/page-with', '')
      
      output.should_receive(:puts).with('200 - http://example.com/page-with#hashtag')
      
      rawler.validate
    end
            
  end
  
  describe "get_status_code" do

    it "should add to 200 links" do
      url = 'http://example.com/foo'
      register(url, '', 200)
      
      rawler.send(:add_status_code, url)
      
      rawler.responses[url][:status].should == 200
    end
    
    it "should add to 302 links" do
      url = 'http://example.com/foo'
      register(url, '', 302)
      
      rawler.send(:add_status_code, url)
      
      rawler.responses[url][:status].should == 302
    end
    
    it "should save username and password" do
      rawler = Rawler::Base.new('http://example.com', output, 'my_user', 'secret')
      
      Rawler.username.should == 'my_user'
      Rawler.password.should == 'secret'
    end
    
    it "should rescue from Errno::ECONNREFUSED" do
      url = 'http://example.com'
      
      Rawler::Request.should_receive(:get).and_raise Errno::ECONNREFUSED
      
      output.should_receive(:puts).with("Connection refused - '#{url}'")
      
      rawler.send(:add_status_code, url)
    end
    
    [Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, Errno::ETIMEDOUT, EOFError,
    Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError].each do |error|
       it "should rescue from #{error}" do
         url = 'http://example.com'

         Rawler::Request.should_receive(:get).and_raise error

         output.should_receive(:puts).with("Connection problems - '#{url}'")

         rawler.send(:add_status_code, url)
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