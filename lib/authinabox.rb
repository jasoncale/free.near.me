#           NAME: authinabox
#        VERSION: 1.01 (Dec 27, 2008)
#         AUTHOR: Peter Cooper [ http://www.rubyinside.com/ github:peterc twitter:peterc ]
#    DESCRIPTION: An "all in one" Sinatra library containing a User model and authentication
#                 system for both session-based logins OR HTTP Basic auth (for APIs, etc).
#                 This is an "all in one" system so you will probably need to heavily tailor
#                 it to your own ideas, but it will work "out of the box" as-is.
#  COMPATIBILITY: - Tested on 0.3.2 AND the latest rtomayko Hoboken build! (recommended for the latter though)
#                 - NEEDS DataMapper!
#                 - Less work needed if you use initializer library -- http://gist.github.com/40238
#                   (remember to turn sessions on!!)
#        LICENSE: Use for what you want, just don't claim full credit unless you make significant changes
#
#   INSTRUCTIONS: To come in full later..
#                 Basically, require in lib/authinabox from your Sinatra app
#                 Tie up login, logout, and signup methods as shown in example at bottom of this file
#                 Use current_user, login_required, etc, from your app (as shown in example)
#                 If you do NOT want .json, .xml, etc, requests going to HTTP Basic auth, head down to line 200.
 
 
 
# ====== DEFAULT OPTIONS FOR PLUGIN ====== 
module Sinatra
  module Plugins
    module AuthInABox
      OPTIONS = { 
        :login_url => '/login',
        :logout_url => '/logout',
        :signup_url => '/signup',
        :after_signup_url => '/dashboard',
        :after_logout_url => '/',
        :template_language => :haml
      }
    end
  end
end
 
 
# ====== USER MODEL ======          
            
# APP_ROOT/models/user.rb
 
 
 
# ====== LOGIC ====== 
 
module Sinatra
  module Plugins
    module AuthInABox
      # ====== CONTROLLERS AND VIEWS ======
      
      # Present login screen (these are really last resorts, you should code your own and call them from your app!)
      def render_login
        if Plugins::AuthInABox::OPTIONS[:template_language] == :haml          
          haml clean(<<-EOS)
                        %h3.form_title Please sign in.
                        %form{ :method => "post" }
                          
                          %p
                            %label{ :for => "user_username" }
                              username or e-mail:
                            %input{ :id => "user_username", :name => "username", :size => 30, :type => "text" }
                          %p
                            %label{ :for => "user_password" }
                              password:
                            %input{ :id => "user_password", :name => "password", :size => 30, :type => "password" }
                          %p
                            %input{ :type => "submit", :value => "login" }
                            .clear
                        EOS
        else
          erb clean(<<-EOS)
          <form method='post'>
            <label>
              username or e-mail:
            </label>
            <input id='user_username' name='username' size='30' type='text' />
            <label>
              password:
            </label>
            <input id='user_password' name='password' size='30' type='password' />
            <input type='submit' value='login' />
          </form>
          EOS
        end
      end
      
      # Log in
      def login
          if user = User.authenticate(params[:username], params[:password])
            session[:user] = user.id
            redirect_to_stored
          else
            redirect Plugins::AuthInABox::OPTIONS[:login_url]
          end
      end
      
      # Log out and delete session info
      def logout
        session[:user] = nil
        redirect Plugins::AuthInABox::OPTIONS[:after_logout_url]
      end
      
      # Present signup page
      def render_signup
        if Plugins::AuthInABox::OPTIONS[:template_language] == :haml
          haml clean(<<-EOS)
                        %h3.form_title Sign up to free.near.me
                        
                        %form{ :action => "#{Plugins::AuthInABox::OPTIONS[:signup_url]}", :method => "post" }
                          -if flash[:error]
                            %p.error= flash[:error]
                        
                          %p
                            %label
                              username:
                            %input{ :id => "user_username", :name => "username", :size => 30, :type => "text" }
                          %p
                            %label
                              email:
                            %input{ :id => "user_email", :name => "email", :size => 30, :type => "text" }
                          %p
                            %label
                              password:
                            %input{ :id => "user_password", :name => "password", :size => 30, :type => "password" }
                          %p
                            %label
                              confirm:
                            %input{ :id => "user_password_confirmation", :name => "password_confirmation", :size => 30, :type => "password" }                            
                          %p
                            %label
                              mobile:
                              %input{ :id => "user_mobile", :name => "mobile", :size => 30, :type => "text" }
                          %p
                            %label
                              twitter username:
                              %input{ :id => "user_twitter", :name => "twitter", :size => 30, :type => "text" }
                          %p
                            %input{ :type => "submit", :value => "sign up" }
                            .clear
                        EOS
        else
          erb clean(<<-EOS)
            <form action='#{Plugins::AuthInABox::OPTIONS[:signup_url]}' method='post'>
              <label>
                username:
              </label>
              <input id='user_username' name='username' size='30' type='text' />
              <label>
                email:
              </label>
              <input id='user_email' name='email' size='30' type='text' />
              <label>
                password:
              </label>
              <input id='user_password' name='password' size='30' type='password' />
              <label>
                confirm:
              </label>
              <input id='user_password_confirmation' name='password_confirmation' size='30' type='password' />
              <input type='submit' value='sign up' />
            </form>
          EOS
        end
      end
      
      def signup
        @user = User.new(:email => params[:email], :username => params[:username], :password => params[:password], :password_confirmation => params[:password_confirmation])
        if @user.save
          session[:user] = @user.id
          flash[:notice] = "Your account has been created"
          redirect Plugins::AuthInABox::OPTIONS[:after_signup_url]
        else
          flash[:error] = "Dude you suck, just fill in the form"
          puts @user.errors.full_messages
          redirect Plugins::AuthInABox::OPTIONS[:signup_url]
        end
      end
      
      
      # ====== HELPERS ======
      helpers do        
        def unauthorized!(realm="ecomo-wizzards.heroku.com")
          response['WWW-Authenticate'] = %(Basic realm="Testing HTTP Auth") and \
          throw(:halt, [401, "Not authorized\n"]) and \
          return 
        end

        def bad_request!
          throw :halt, [ 400, 'Bad Request' ]
        end
          
        def authorize(username, password)
          !User.authenticate(username, password).blank?
        end
        
        def login_required
          if authorized?
            return true
          else
            unauthorized! unless auth.provided?
            bad_request! unless auth.basic?
            unauthorized! unless authorize(*auth.credentials)
            
            request.env['REMOTE_USER'] = auth.username
            session[:user] = User.first(:username => auth.credentials.first).id
            return true
          end
        end
        
        def auth
          @auth ||= Rack::Auth::Basic::Request.new(request.env)
        end
        
        def authorized?
          !session[:user].blank?
        end
          
        def current_user
          User.get(session[:user])
        end
          
        def redirect_to_stored
          if return_to = session[:return_to]
            session[:return_to] = nil
            redirect return_to
          else
            redirect '/'
          end
        end
        
        # Cleans indentation for heredocs
        def clean(str); str.gsub(/^\s{#{str[/\s+/].length}}/, ''); end
      end
 
    end
  end
end
 
# Little hack to make inclusion work with both Sinatra 0.3.2 and latest experimental builds
(Sinatra::Base rescue Sinatra::EventContext).send(:include, Sinatra::Plugins::AuthInABox) 
 
# Get database up to date
# DataMapper.auto_upgrade!