class Item
  include DataMapper::Resource
  
  property :id, Serial, :writer => :protected, :key => true
  
  property :title, String, :nullable => false
  property :description, Text
  property :created_at, DateTime

  belongs_to :listing_source
  
end