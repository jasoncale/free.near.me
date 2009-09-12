require 'httparty'
require 'uri'

module RemoteListings
  
  class Base
    include HTTParty
          
    class << self
    
      def permalink_for(item)
        URI.join(base_uri, item.to_param)
      end
      
    #   def recent(options = {})
    #     options = {:since => Time.now}.merge(options)
    # 
    #     lookup(options)
    #   end
    #   
    #   def lookup(options = {})
    #     []
    #   end
    
    end
     
  end
  
end