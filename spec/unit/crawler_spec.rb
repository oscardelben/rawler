require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Rawler::Crawler do
  
  let(:url) { 'http://example.com' }
  
  before(:each) do
    Rawler.stub!(:url).and_return(url)
  end
  
  it "should parse all links" do
    register(url, site)
    
    Rawler::Crawler.new(url).links.should == ['http://example.com/foo', 'http://external.com/bar']
  end
  
  it "should parse relative links" do
    url = 'http://example.com/path'
    register(url, '<a href="/foo">foo</a>')
    
    Rawler::Crawler.new(url).links.should == ['http://example.com/foo']
  end
  
  it "should parse links only if the page is in the same domain as the main url" do
    url = 'http://external.com/path'
    register(url, '<a href="/foo">foo</a>')
    
    Rawler.should_receive(:url).and_return('http://example.com')
    
    Rawler::Crawler.new(url).links.should == []
  end
  
  it "should return an empty array when raising Errno::ECONNREFUSED" do
    register(url, site)
    crawler = Rawler::Crawler.new(url)
    
    Rawler::Request.should_receive(:get).and_raise Errno::ECONNREFUSED
    
    crawler.links.should == []
  end
  
  it "should print a message when raising Errno::ECONNREFUSED" do
    output = double('output')
    register(url, site)
    
    crawler = Rawler::Crawler.new(url)
    
    Rawler::Request.should_receive(:get).and_raise Errno::ECONNREFUSED
    Rawler.should_receive(:output).and_return(output)    
    output.should_receive(:puts).with("Couldn't connect to #{url}")
    
    crawler.links
  end
  
  context "should ignore content type other than text/html" do
    
    ['text/plain', 'text/css', 'image/jpeg'].each do |content_type|
      
      it "should ignore '#{content_type}'" do
        register(url, site, 200, :content_type => content_type)

        crawler = Rawler::Crawler.new(url)
        crawler.links.should == []
      end
      
    end
    
  end
  
  it "should ignore links other than http or https" do
    content = <<-content
      <a href="http://example.com/valid">foo</a>
      <a href="mailto:info@example.com">invalid</a>
      <a href="https://foo.com">valid</a>
    content
    
    register(url, content)
    
    crawler = Rawler::Crawler.new(url)
    crawler.links.should == ['http://example.com/valid', 'https://foo.com']
  end
  
  private
  
  def site
    <<-site
      <!DOCTYPE html>
      <html>
      	<body>
      		<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>

      		<p><a href="http://example.com/foo">foo</a></p>

      		<p><a href="http://external.com/bar">bar</a></p>

      	</body>
      </html>
    site
  end
  
end
