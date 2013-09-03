# encoding: UTF-8

require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe Rawler::Crawler do

  let(:url)    { 'http://example.com' }
  let(:output)  { double('output', :error => nil) }

  before(:each) do
    Rawler.stub(:url).and_return(url)
    Rawler.stub(:output).and_return(output)
  end

  context "basic functionality" do

    let(:url) { 'http://example.com' }
    let(:crawler) { Rawler::Crawler.new(url) }
    let(:content) {
      content = <<-content
        <link rel="stylesheet" href="css/styles.css" />
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

    it "should parse css links" do
      crawler.css_links.should == ['http://example.com/css/styles.css']
    end
  end

  context "relative paths" do

    context "base URL ends with a slash" do

      let(:url)     { 'http://example.com/dir1/dir2/' }
      let(:crawler) { Rawler::Crawler.new(url) }
      let(:content) { '<a href="/foo">foo</a> <a href="bar">bar</a> <a href="../baz">baz</a>' }

      before(:each) do
        register(url, content)
      end

      it "should parse relative links" do
        crawler.links.should == ['http://example.com/foo', 'http://example.com/dir1/dir2/bar', 'http://example.com/dir1/baz']
      end

    end

    context "base URL doesn't end with a slash" do

      let(:url)     { 'http://example.com/dir1/dir2' }
      let(:crawler) { Rawler::Crawler.new(url) }
      let(:content) { '<a href="/foo">foo</a> <a href="bar">bar</a> <a href="../baz">baz</a>' }

      before(:each) do
        register(url, content)
      end

      it "should parse relative links" do
        crawler.links.should == ['http://example.com/foo', 'http://example.com/dir1/bar', 'http://example.com/baz']
      end

    end

  end

  context "different domains" do

    let(:url)     { 'http://external.com/path' }
    let(:crawler) { Rawler::Crawler.new(url) }
    let(:content) { '<a href="/foo">foo</a>' }

    before(:each) do
      Rawler.stub(:url).and_return('http://example.com')
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

    it "should not encode hashtags" do
      crawler.links.should == ['http://example.com/foo#bar']
    end

  end

  context "urls with unicode characters" do

    let(:url)     { 'http://example.com' }
    let(:crawler) { Rawler::Crawler.new(url) }
    let(:content) { '<a href="http://example.com/写程序容易出现的几个不好的地方">foo</a>' }

    before(:each) do
      register(url, content)
    end

    it "should parse unicode links" do
      crawler.links.should == ['http://example.com/%E5%86%99%E7%A8%8B%E5%BA%8F%E5%AE%B9%E6%98%93%E5%87%BA%E7%8E%B0%E7%9A%84%E5%87%A0%E4%B8%AA%E4%B8%8D%E5%A5%BD%E7%9A%84%E5%9C%B0%E6%96%B9']
    end

  end

  context "invalid urls" do

    context "javascript" do
      let(:url)     { 'http://example.com/path' }
      let(:crawler) { Rawler::Crawler.new(url) }
      let(:js_url)  { "javascript:fn('nbjmup;jhfs.esf{fio/dpn');" }
      let(:content) { "<a href=\"#{js_url}\">foo</a><a name=\"foo\">" }

      before(:each) do
        register(url, content)
      end

      it "should return empty links" do
        crawler.links.should == []
      end

      it "should not report the error" do
        crawler.should_not_receive(:write)
        crawler.links
      end
    end

    context "mailto" do
      let(:url)     { 'http://example.com/path' }
      let(:crawler) { Rawler::Crawler.new(url) }
      let(:content) { "<a href=\"mailto:example@example.com\">foo</a><a name=\"foo\">" }

      before(:each) do
        register(url, content)
      end

      it "should return empty links" do
        crawler.links.should == []
      end

      it "should not report the error" do
        crawler.should_not_receive(:write)
        crawler.links
      end
    end

    context "callto" do
      let(:url)     { 'http://example.com/path' }
      let(:crawler) { Rawler::Crawler.new(url) }
      let(:content) { "<a href=\"callto:home22\">foo</a><a name=\"foo\">" }

      before(:each) do
        register(url, content)
      end

      it "should return empty links" do
        crawler.links.should == []
      end

      it "should not report the error" do
        crawler.should_not_receive(:write)
        crawler.links
      end
    end

    context "skip matches" do
      let(:url)     { 'http://example.com/path' }
      let(:crawler) { Rawler::Crawler.new(url) }
      let(:content) { "<a href=\"http://example.com/search/page:1/\">foo</a><a href=\"http://example.com/search/page:2/\">foo</a>" }

      before(:each) do
        Rawler.set_skip_pattern('\/search\/(.*\/)?page:[2-9]', false)
        register(url, content)
      end

      it "should return one links" do
        crawler.links.length.should eql(1)
      end

      it "should not report that it's skipping" do
        crawler.should_not_receive(:write)
        crawler.links
      end

      after(:each) do
        Rawler.set_skip_pattern(nil)
      end
    end

    context "case-insensitive skip matches" do
      let(:url)     { 'http://example.com/path' }
      let(:crawler) { Rawler::Crawler.new(url) }
      let(:content) { "<a href=\"http://example.com/search/page:1/\">foo</a><a href=\"http://example.com/search/page:2/\">foo</a>" }

      before(:each) do
        Rawler.set_skip_pattern('\/seArcH\/(.*\/)?PAGE:[2-9]', true)
        register(url, content)
      end

      it "should return one links" do
        crawler.links.length.should eql(1)
      end

      it "should not report that it's skipping" do
        crawler.should_not_receive(:write)
        crawler.links
      end

      after(:each) do
        Rawler.set_skip_pattern(nil)
      end
    end

    context "include matches" do
      let(:url)     { 'http://example.com/path' }
      let(:crawler) { Rawler::Crawler.new(url) }
      let(:content) { "<a href=\"http://example.com/search/page:1/\">foo</a><a href=\"http://example.com/search/page:2/\">foo</a>" }

      before(:each) do
        Rawler.set_include_pattern('\/search\/(.*\/)?page:[2-9]', false)
        register(url, content)
      end

      it "should return one links" do
        crawler.links.length.should eql(1)
        crawler.links.should eq(['http://example.com/search/page:2/'])
      end

      it "should not report that it's including" do
        crawler.should_not_receive(:write)
        crawler.links
      end

      after(:each) do
        Rawler.set_include_pattern(nil)
      end
    end

    context "case-insensitive include matches" do
      let(:url)     { 'http://example.com/path' }
      let(:crawler) { Rawler::Crawler.new(url) }
      let(:content) { "<a href=\"http://example.com/search/page:1/\">foo</a><a href=\"http://example.com/search/page:2/\">foo</a>" }

      before(:each) do
        Rawler.set_include_pattern('\/seArcH\/(.*\/)?PAGE:[2-9]', true)
        register(url, content)
      end

      it "should return one links" do
        crawler.links.length.should eql(1)
      end

      it "should not report that it's including" do
        crawler.should_not_receive(:write)
        crawler.links
      end

      after(:each) do
        Rawler.set_include_pattern(nil)
      end
    end

    context "non-local site should be omitted when local flag is used" do
      let(:url)     { 'http://example.com/' }
      let(:crawler) { Rawler::Crawler.new(url) }
      let(:content) { "<a href=\"http://example.com/page1/\">foo</a><a href=\"http://example.org/page2\">foo</a>" }

      before(:each) do
        Rawler::local = true
        register(url, content)
      end

      it "should return one link" do
        crawler.links.length.should eql(1)
      end

      it "should not report that it's skipping" do
        crawler.should_not_receive(:write)
        crawler.links
      end

      after(:each) do
        Rawler::local = false
      end
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

    before(:each) do
      register(url, '')
    end

    context "Errno::ECONNREFUSED" do

      before(:each) do
        Rawler::Request.stub(:get).and_raise Errno::ECONNREFUSED
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
        Rawler::Request.stub(:get).and_raise Errno::ETIMEDOUT
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

      Rawler.stub(:username).and_return('foo')
      Rawler.stub(:password).and_return('bar')
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

  context "invalid urls" do
    let(:content) { '<a href="http://foo;bar">foo</a>' }
    let(:url)     { 'http://example.com' }
    let(:crawler) { Rawler::Crawler.new(url) }

    before(:each) do
      register(url, content)
    end

    it "should notify about the invalid url" do
      output.should_receive(:error).with('Invalid url: http://foo;bar - Called from: http://example.com')
      crawler.links.should == []
    end
  end

  context "invalid mailto" do
    let(:content) { '<a href="mailto:obfuscated(at)example(dot)com">foo</a>' }
    let(:url)     { 'http://example.com' }
    let(:crawler) { Rawler::Crawler.new(url) }

    before(:each) do
      register(url, content)
    end

    it "should notify about the invalid url" do
      output.should_receive(:error).with('Invalid url: mailto:obfuscated(at)example(dot)com - Called from: http://example.com')
      crawler.links.should == []
    end
  end

end
