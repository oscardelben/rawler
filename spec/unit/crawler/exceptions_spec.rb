require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe Rawler::Crawler do
  
  context "Exceptions" do
    
    let(:url)     { 'http://example.com' }
    let(:crawler) { Rawler::Crawler.new(url) }
    let(:output)  { double('output', :puts => nil) }
    
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
        output.should_receive(:puts).with("Couldn't connect to #{url}")

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
        output.should_receive(:puts).with("Connection to #{url} timed out")

        crawler.links
      end
  
    end
    
  end
  
end