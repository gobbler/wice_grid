lib_dir = File.dirname(__FILE__) + '/../lib'
$LOAD_PATH.unshift lib_dir unless $LOAD_PATH.include? lib_dir

require 'rubygems'

gemfile = File.expand_path('Gemfile', __FILE__)
begin
  ENV['BUNDLE_GEMFILE'] = gemfile
  require 'bundler'
  Bundler.setup
rescue Bundler::GemNotFound => e
  STDERR.puts e.message
  STDERR.puts "Try running `bundle install`."
  exit!
end if File.exist?(gemfile)

require 'bundler'
Bundler.require(:default, 'test')# if defined?(Bundler)

