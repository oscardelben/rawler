require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Rawler::Formatter do
  
  it "should save output" do
    output = double('output')
    Rawler::Base.new('http://example.com', output)
    
    Rawler::Formatter.output.should == output
  end
  
end