require File.join(File.dirname(__FILE__), '/require_gems')
require File.join(File.dirname(__FILE__), '/rails_test_app')

require 'capybara'
require 'capybara/dsl'
Capybara.app = Rails.application

RSpec.configure do |rspec_config|
  rspec_config.before(:each) do
    Mongoid.configure do |mongoid_config|
      name = "test_wice_grid"
      host = "localhost"
      mongoid_config.master = Mongo::Connection.new.db(name)
      mongoid_config.master.collections.select{ |c| c.name != 'system.indexes' }.each { |c| c.drop }
    end
  end
end

require 'test/blueprint'
