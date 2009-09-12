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
        :items => items
      }]
    }
  end
  
  def items
    Item.search(
      :q => self.query,
      :lat => user.lat,
      :long => user.long
    )
  end
  
  class << self
    
    def Poll
      self.all.each do |search|
        items = search.items
        
        if items.present?
          items.select {|item| item.created >= search.updated_at }.each(&:notify_user)
        end
      end
    end
  
  end

end