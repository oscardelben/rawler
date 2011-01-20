require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe Rawler::Crawler do
  
  context "url domain" do
    
    let(:content) {
      content = <<-content
        <a href="http://example.com/valid">foo</a>
        <a href="mailto:info@example.com">invalid</a>
        <a href="https://foo.com">valid</a>
      content
    }
    let(:url)     { 'http://example.com' }
    let(:crawler) { Rawler::Crawler.new(url) }
    
    before(:each) do
      register(url, content)
    end
  
    it "should ignore links other than http or https" do
      crawler.links.should == ['http://example.com/valid', 'https://foo.com']
    end
  end

end