require 'machinist/mongoid'
require 'sham'
require 'faker'

Sham.first_name { Faker::Internet.user_name }

User.blueprint do
  first_name 
  year { Time.parse('1980-01-01') }
  last_login { Time.parse('1980-01-01 11:00')}
  computers_number { 1 }
  archived { false }
  storage_limit { 10*1024*1024*1024 }
end

Computer.blueprint do
end

