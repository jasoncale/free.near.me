APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'rubygems'
$:.unshift File.join(APP_ROOT, 'vendor', 'sinatra', 'lib')
require 'sinatra'
require 'json'
require 'lib/initializer'
require 'lib/authinabox'
require 'lib/remote_listings/init'

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
  
  
  # API
  
  get '/search.json' do
    login_required
    content_type "text/json"
    
    {
      :items => Item.search(params).to_json
    }
  end
  
  get '/search/list.json' do
    login_required
    content_type "text/json"
    
    {
      :searches => current_user.searches.map(&:results)
    }.to_json
  end
  
  post '/search.json' do
    login_required
    content_type "text/json"
    
    search = current_user.searches.new(
      :query => params[:q], 
      :distance => params[:distance]
    )
    
    if search.save
      search.results.to_json
    else
      status 422
      '{name: "JSONRequestError", message: "bad data"}'
    end
  end
  
  delete '/search/:id' do
    login_required
    destroy_search(params[:id])
    redirect '/dashboard'
  end
  
  def destroy_search(id)
    if search = current_user.searches.get(id)
      search.destroy
    else
      false
    end
  end
  
end

