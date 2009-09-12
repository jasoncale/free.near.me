require 'geokit'

class Search
  include DataMapper::Resource
  
  property :id, Serial, :writer => :protected, :key => true
  property :created_at, DateTime
  property :updated_at, DateTime
  
  property :query, String, :nullable => false
  property :search_distance, Integer, :default => 25
  
  belongs_to :user
  
  validates_present :query
  validates_is_unique :query, :scope => :user_id

  def to_json(*a)
    {
      'id' => id,
      'query' => query,
      'distance' => search_distance,
      'created_at' => created_at,
      'updated_at' => updated_at,
      'lat' => user.lat,
      'lon' => user.lon,
      'items' => items
    }.to_json(*a)
  end  

  def items
    Item.search(
      
      {
        :q => self.query,
        :sw_lat => sw_lat,
        :sw_lng => sw_lng,
        :ne_lat => ne_lat,
        :ne_lng => ne_lng
      }.reject{|k,v| v.blank? }
      
    )
  end

  attr_accessor :sw_lat, :sw_lng, :ne_lat, :ne_lng
  
  def distance=(value)
    self.search_distance = value
    
    unless self.user.blank?
      unless (self.user.lat.blank? || self.user.lon.blank?)
        bounds = GeoKit::Bounds.from_point_and_radius([self.user.lat, self.user.lon], value.to_i)

        self.sw_lat = bounds.sw.lat
        self.sw_lng = bounds.sw.lng
        self.ne_lat = bounds.ne.lat
        self.ne_lng = bounds.ne.lng
      end
    end
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
    
    def poll
      self.all.each do |search|
        items = search.items
        unless items.empty?
          items.select {|item| item.created >= search.updated_at }.each do |new_item|
            search.notify_user_of(new_item)
          end
        end
      end
    end
  
  end

end