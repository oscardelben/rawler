# encoding: utf-8

require 'rubygems'
require 'bundler'
require 'fileutils'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "rawler"
  gem.homepage = "http://github.com/oscardelben/rawler"
  gem.license = "MIT"
  gem.summary = %Q{Rawler is a tool that crawls the links of your website}
  gem.description = %Q{Rawler is a tool that crawls the links of your website}
  gem.email = "info@oscardelben.com"
  gem.authors = ["Oscar Del Ben"]
  gem.executables = ['rawler']
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rawler #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
