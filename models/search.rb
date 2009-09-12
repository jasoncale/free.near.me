class Search
  include DataMapper::Resource
  
  property :id, Serial, :writer => :protected, :key => true
  property :created_at, DateTime
  property :updated_at, DateTime
  
  property :query, String, :nullable => false
  property :distance, Integer, :default => 25
  
  property :sw_lat, String
  property :sw_lng, String
  property :ne_lat, String
  property :ne_lng, String
  
  validates_present :password_confirmation

end