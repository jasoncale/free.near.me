require 'httparty'

class Tweet
  include HTTParty
  base_uri 'twitter.com'
  basic_auth "freenearme", "r433h3q4j3"
  format :json
  
  class << self
  
    def notify(text)
      post('/statuses/update.json', { :query => {:status => text} })
    end    
  
  end
  
end