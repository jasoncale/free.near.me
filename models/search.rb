class Search
  include DataMapper::Resource
  
  property :id, Serial, :writer => :protected, :key => true
  property :created_at, DateTime
  property :updated_at, DateTime
  
  property :query, String, :nullable => false
  property :distance, Integer, :default => 25
  
  belongs_to :user
  
  validates_present :query
  validates_is_unique :query, :scope => :user_id
  
  def results
    { 
      :search => [self, { 
        :items => Item.search(
          :q => self.query,
          :lat => user.lat,
          :long => user.long
        )
      }]
    }
  end
  
  class << self
    
    def Poll
      self.all.each do |search|
        
      end
    end
  
  end

end