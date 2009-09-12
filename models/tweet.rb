require 'httparty'

class Tweet
  include HTTParty
  base_uri 'twitter.com'
  basic_auth "ecomowdf", "3d9j92er"
  format :json
  
  class << self
  
    def notify(text)
      post('/statuses/update.json', { :query => {:status => text} })
    end    
  
  end
  
end