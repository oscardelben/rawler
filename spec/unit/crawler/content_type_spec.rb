require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe Rawler::Crawler do

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
  
end