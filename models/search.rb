class Search
  include DataMapper::Resource
  
  property :id, Serial, :writer => :protected, :key => true
  property :created_at, DateTime
  property :updated_at, DateTime
  
  property :query, String, :nullable => false
  property :distance, Integer, :default => 25
  
  belongs_to :user
  
  validates_present :query
  #validates_is_unique :query, :scope => :user_id

  def to_json(*a)
    {
      'id' => id,
      'query' => query,
      'distance' => distance,
      'created_at' => created_at,
      'updated_at' => updated_at,
      'lat' => user.lat,
      'lon' => user.long,
      'items' => items
    }.to_json(*a)
  end  

  def items
    Item.search(
      :q => self.query,
      :lat => user.lat,
      :long => user.long
    )
  end
  
  def notify_user_of(item)
    if search.notification_method.present?
      self.send("notify_" + search.notification_method, item)
    end
  end
  
  def notify_twitter(item)
    Tweet.notify("@#{self.user.twitter} #{item.title} #{item.permalink}")
  end
  
  class << self
    
    def Poll
      self.all.each do |search|
        items = search.items
        if items.present?
          items.select {|item| item.created >= search.updated_at }.each do |new_item|
            search.notify_user_of(new_item)
          end
        end
      end
    end
  
  end

end