# -*- ruby -*-

require 'rubygems'
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

# vim: syntax=ruby
