module RemoteListings
  
  class Reyooz < Base    
    
    base_uri 'reyooz.com'
    format :json
    
    class << self
    
      def lookup(search, query_arguments = {})
                
        query_arguments = { 
          :sw_lat => 51.319026, 
          :sw_lng => -0.487518, 
          :ne_lat => 51.667019, 
          :ne_lng => 0.16204,
          :q => search
        }.merge(query_arguments)
                
        if results = get('/items', :query => query_arguments)
          return results["items"]
        end
        
      end
      
      def ident
        'reyooz'
      end
    
    end
  end
  
end