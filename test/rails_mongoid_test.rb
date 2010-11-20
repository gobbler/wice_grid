require File.join(File.dirname(__FILE__), '/test_helper2')

module Test
  class Application < Rails::Application
  end
end

class User
  include Mongoid::Document
end


