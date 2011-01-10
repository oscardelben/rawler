require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Rawler::Crawler do
  
  it "should parse all links" do
    url = 'http://example.com'
    register(url, site)
    
    Rawler::Crawler.new(url).links.should == ['http://example.com/foo', 'http://external.com/bar']
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
