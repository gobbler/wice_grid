require File.join(File.dirname(__FILE__), '/test_helper2')

require "action_controller/railtie"
require "active_resource/railtie"
require 'wice_grid'

module Test
  class Application < Rails::Application
    #config.root_path = File.join(File.dirname(__FILE__), 'rails')
    config.secret_token = '84198d9ba8d271b3d95d252b17601cb0f4b18b5a790d0c1d9bcce95e1c03d9d6f615b21b66986a2bf2ea9b5e850e30f09dfbfa9ffa2586b8ce1f5f1a2e4a460d'
  end
end

class User
  include Mongoid::Document
  field :first_name
    def self.merge_conditions(*conditions)
      ""
    end
end

class UsersController < ActionController::Base
  def index
    @users_grid = initialize_grid(User)
    render :inline => <<TEMPLATE 
<%= grid(@users_grid) do |g|
    g.column :column_name => 'First Name', :attribute_name => 'first_name'
end
%>
TEMPLATE
  end
end

Test::Application.initialize!
Test::Application.routes.draw do
   resources :users
end

require 'capybara'
require 'capybara/dsl'
Capybara.app = Rails.application

require 'test/wice_grid_initializer'


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

describe UsersController do
  include Capybara
  
  context "3 users" do
    before(:each) do
      @aa = User.make(:first_name => 'aabbcc')
      @bb = User.make(:first_name => 'bbccdd')
      @cc = User.make(:first_name => 'ccddee')
      visit '/users'
    end
    
    it "should render grid as table" do
      page.should have_selector('table tr')
    end

    it "should be possible to sort it by clicking titles" do
      page.should_not have_selector '.asc'
      page.should_not have_selector '.desc'
      
      click_link 'First Name'
      page.should have_selector '.asc'
      first_name_column = all('td[1]').map(&:text)
      first_name_column.should == ["aabbcc", "bbccdd", "ccddee"]
      
      click_link 'First Name'
      page.should have_selector '.desc'
      first_name_column = all('td[1]').map(&:text)
      first_name_column.should == ["ccddee", "bbccdd", "aabbcc"]
    end
end
  
end  

