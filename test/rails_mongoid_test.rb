require File.join(File.dirname(__FILE__), '/test_helper2')

require "action_controller/railtie"
require "active_resource/railtie"
require 'wice_grid'

RSpec.configure do |config|
end

module Test
  class Application < Rails::Application
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

Mongoid.configure do |config|
  name = "test_wice_grid"
  host = "localhost"
  config.master = Mongo::Connection.new.db(name)
end

describe UsersController do
  include Capybara
  
  it "should render grid as table" do
    visit '/users'
    page.should have_selector('table tr')
  end
end  

