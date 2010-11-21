require 'machinist/mongoid'
require 'sham'
require 'faker'

Sham.first_name { Faker::Internet.user_name }

User.blueprint do
  first_name 
end


