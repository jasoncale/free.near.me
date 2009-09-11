APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'rubygems'
$:.unshift File.join(APP_ROOT, 'vendor', 'sinatra', 'lib')
require 'sinatra'
require 'lib/initializer'
require 'lib/authinabox'

class EcomoWizzard < Sinatra::Application
  
  set :root, APP_ROOT  

  get '/' do
    haml :index
  end
  
  get '/login' do
    render_login    # or render your own equivalent!
  end
  
  post '/login' do
    login
  end
  
  get '/signup' do
    render_signup   # or render your own equivalent!
  end
  
  post '/signup' do
    signup
  end
  
  get '/logout' do
    logout
  end
  
  
  # SEARCHING STUFF
  
  get '/dashboard' do
    login_required
    haml :dashboard
  end
  
  
  # get '/api.json' do
  #   login_required
  #   content_type "text/json"
  #   "{ 'a': 'b' }"
  # end  
  

end

