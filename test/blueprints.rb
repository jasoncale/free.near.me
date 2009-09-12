require 'machinist/data_mapper' 
require 'sham' 
require 'faker'

Sham.define do
  title { Faker::Lorem.sentence }
  name  { Faker::Name.name }
  body  { Faker::Lorem.paragraph }
  
  email { Faker::Internet.email }
  username { Faker::Internet.user_name.gsub(/\./, '_') }
  password { Faker::Lorem.words.join }
end

User.blueprint do
  email
  username
  password
  password_confirmation { password }
end