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
      'id' => id,
      'title' => title,
      'description' => description,
      'created' => created,
      'lat' => lat,
      'lon' => long,
      'source' => source.ident,
      'url' => url
    }.to_json(*a)
  end
  
  alias :url :permalink
  
  class << self
  
    def search(params)
      (parse_reyoos(params) + []).flatten
    end
    
    def parse_reyoos(params)
      RemoteListings::Reyooz.lookup(params.delete(:q), params).map do |item|
        Item.new(
          item["id"],
          item["title"],
          item["description"],
          item["created_at"],
          item["lat"],
          item["lng"],
          RemoteListings::Reyooz
        )
      end.sort {|a,b| a.created <=> b.created }.reverse
    end
  
  end
  
end