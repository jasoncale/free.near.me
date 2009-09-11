require 'uri'

class ListingSource
  include DataMapper::Resource
  
  property :id, Serial, :writer => :protected, :key => true
  property :base_uri, String, :nullable => false
  
  has n, :items
    
  def permalink_for(item)
    URI.join(base_uri, item.to_param)
  end
  
end