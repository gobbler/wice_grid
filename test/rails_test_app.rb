require "action_controller/railtie"
require "active_resource/railtie"
require_relative '../lib/wice_grid'

module Test
  class Application < Rails::Application
    config.secret_token = '84198d9ba8d271b3d95d252b17601cb0f4b18b5a790d0c1d9bcce95e1c03d9d6f615b21b66986a2bf2ea9b5e850e30f09dfbfa9ffa2586b8ce1f5f1a2e4a460d'
    config.public_path = File.join(File.dirname(__FILE__), '/public')
  end
end

class Computer
  include Mongoid::Document
  belongs_to_related	:user
  field :name
end

class User
  include Mongoid::Document
  
  #identity :type => String
  field :first_name
  field :year, :type => Date
  field :last_login, :type => Time
  field :computers_number, :type => Integer
  field :archived, :type => Boolean
  field :storage_limit, :type => Integer

  def self.merge_conditions(*conditions)
    ""
  end
end

class UsersController < ActionController::Base
  
  def self.columns(&block)
    @@define_columns = block
  end   
  
  def columns(grid)
    @@define_columns.call(grid)
  end
  
  def index
    @users_grid = initialize_grid(User)
    render :inline => <<TEMPLATE 

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html lang='en_us' xml:lang='en_us' xmlns='http://www.w3.org/1999/xhtml'>
   <head>
		<%= javascript_include_tag "jquery-1.4.2.min" %>
        <%= include_wice_grid_assets %>
   </head>
   <body>
<%= 
     grid(@users_grid) do |g|
       controller.columns(g)
     end
%>
   </body>
</html>
TEMPLATE
  end
end

Test::Application.initialize!
Test::Application.routes.draw do
  resources :users
end

require_relative './wice_grid_initializer'
