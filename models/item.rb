class Item
  
  def self.search(params)
    [
      RemoteListings::Reyooz.lookup(params.delete(:q), params)
    ].flatten
  end
  
end