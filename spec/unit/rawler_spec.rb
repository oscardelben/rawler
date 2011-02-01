require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Rawler do

  describe "url=" do

    context "given a URL without http://" do

      it "should prepend http://" do
        Rawler.url = 'www.example.com'
        Rawler.url.should == 'http://www.example.com'
      end

    end

    context "given a URL beginning with http://" do

      it "should not modify the url" do
        Rawler.url = 'http://www.example.com'
        Rawler.url.should == 'http://www.example.com'
      end

    end
    
    context "given a URL beginning and ending with illegal whitespace" do

      it "should strip and parse it correctly" do
        Rawler.url = ' http://www.example.com '
        Rawler.url.should == 'http://www.example.com'
      end

    end

  end
  
end
