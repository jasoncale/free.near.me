class Item
  
  attr_accessor :id, :title, :description, :created, :lat, :long, :source
  
  def initialize(id, title, description, created, lat, long, source)
    @id = id
    @title = title
    @description = description
    @created = created
    @lat = lat
    @long = long    
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
      'item' => {
        'id' => id,
        'title' => title,
        'description' => description,
        'created' => created,
        'lat' => lat,
        'long' => long,
        'source' => source.ident,
        'url' => url
      }
    }.to_json(*a)
  end

  def self.json_create(o)
    new(*o['data'])
  end
  
  alias :url :permalink
  
  class << self
  
    def search(params)
      {
        :items => parse_reyoos(params)
      }
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
      end
    end
  
  end
  
end