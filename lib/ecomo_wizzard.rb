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
    
    @searches = current_user.searches
    
    haml :dashboard
  end
  
  
  # API
  
  get '/search.json' do
    login_required
    content_type "text/json"
    
    Item.search(params).to_json
  end
  
  get '/search/list.json' do
    login_required
    update_user_location
    content_type "text/json"
    
    current_user.searches.to_a.to_json
  end
  
  post '/search.json' do
    login_required
    update_user_location
    content_type "text/json"
    
    search = current_user.searches.new(
      :query => params[:q], 
      :distance => params[:distance]
    )
      
    if search.save
      search.to_json
    else
      status 422
      '{name: "JSONRequestError", message: "bad data"}'
    end
  end
  
  get '/style.css' do  
    content_type 'text/css', :charset => 'utf-8'
    sass :stylesheet
  end
  
  delete '/search/:id' do
    login_required
    destroy_search(params[:id])
    redirect '/dashboard'
  end
  
  def flash
    session[:flash] = {} if session[:flash] && session[:flash].class != Hash
    session[:flash] ||= {}
  end
  
  private
  
  def destroy_search(id)
    if search = current_user.searches.get(id)
      search.destroy
    else
      false
    end
  end
  
  def update_user_location
    if params[:lat] && params[:lon]
      current_user.update_location(params[:lat], params[:lon])
    end
  end
  
end

