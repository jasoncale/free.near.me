class Item
  
  def self.search(params)
    {
      :items => [
        RemoteListings::Reyooz.lookup(params.delete(:q), params)
      ].flatten
      
    }  
  
  end
  
end