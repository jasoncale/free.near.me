class Item
  
  attr_accessor :id, :title, :description, :created, :lat, :lon, :source
  
  def initialize(id, title, description, created, lat, lon, source)
    @id = id
    @title = title
    @description = description
    @created = created
    @lat = lat
    @lon = lon    
    @source = source
  end
   
  def permalink
    source.permalink_for(self)
  end
  
  def to_param
    id
  end
  
  def to_json(*a)
    {
      'id' => id,
      'title' => title,
      'description' => description,
      'created' => created,
      'lat' => lat,
      'lon' => lon,
      'source' => source.ident, 
      'url' => url
    }.to_json(*a)
  end
  
  alias :url :permalink
  
  class << self
  
    def search(params = {})
      (parse_reyoos(params) + []).flatten
    end
    
    def parse_reyoos(params)
      RemoteListings::Reyooz.lookup(params.delete(:q), params).map do |item|
        Item.new(
          item["item"]["id"],
          item["item"]["title"],
          item["item"]["description"],
          item["item"]["created_at"],
          item["item"]["lat"],
          item["item"]["lng"],
          RemoteListings::Reyooz
        )
      end.sort {|a,b| a.created <=> b.created }.reverse
    end
  
  end
  
end