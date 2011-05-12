# -*- ruby -*-

require 'rubygems'
require 'fileutils'
require 'hoe'

# require 'bundler'
# Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:test)

# Hoe.plugin :compiler
# Hoe.plugin :gem_prelude_sucks
# Hoe.plugin :inline
# Hoe.plugin :racc
# Hoe.plugin :rubyforge

Hoe.spec 'rawler' do
  # HEY! If you fill these out in ~/.hoe_template/Rakefile.erb then
  # you'll never have to touch them again!
  # (delete this comment too, of course)

  developer('Oscar Del Ben', 'info@oscardelben.com')

  self.rubyforge_name = 'oscardelben'
  
  extra_deps << ['nokogiri']
end

desc 'Console'
task :console do
  exec 'irb -rubygems -I lib -r rawler.rb'
end

desc 'generate docs'
task :rocco do
  #%x!rm -r html/*!

  Dir.chdir "lib"

  files = Dir['**/*.*']
  
  files.each do |file|
    %x!rocco #{file} -o ../html!
  end
end

# vim: syntax=ruby
