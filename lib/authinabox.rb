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
        :template_language => :erb
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
                        %form{ :method => "post" }
                          %label
                            username or e-mail:
                          %input{ :id => "user_username", :name => "username", :size => 30, :type => "text" }
                          %label
                            password:
                          %input{ :id => "user_password", :name => "password", :size => 30, :type => "password" }
                          %input{ :type => "submit", :value => "login" }
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
                        %form{ :action => "#{Plugins::AuthInABox::OPTIONS[:signup_url]}", :method => "post" }
                          %label
                            username:
                          %input{ :id => "user_username", :name => "username", :size => 30, :type => "text" }
                          %label
                            email:
                          %input{ :id => "user_email", :name => "email", :size => 30, :type => "text" }
                          %label
                            password:
                          %input{ :id => "user_password", :name => "password", :size => 30, :type => "password" }
                          %label
                            confirm:
                          %input{ :id => "user_password_confirmation", :name => "password_confirmation", :size => 30, :type => "password" }
                          %input{ :type => "submit", :value => "sign up" }
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
          redirect Plugins::AuthInABox::OPTIONS[:after_signup_url]
        else
          puts @user.errors.full_messages
          redirect Plugins::AuthInABox::OPTIONS[:signup_url]
        end
      end
      
      
      # ====== HELPERS ======
      helpers do
        def login_required
          if session[:user]
            return true
          elsif request.env['REQUEST_PATH'] =~ /(\.json|\.xml)$/ && request.env['HTTP_USER_AGENT'] !~ /Mozilla/
              @auth ||= Rack::Auth::Basic::Request.new(request.env)
              if @auth.provided? && @auth.basic? && @auth.credentials && User.authenticate(@auth.credentials.first, @auth.credentials.last)
                session[:user] = User.first(:username => @auth.credentials.first).id
                return true
              else
                status 401
                halt("401 Unauthorized") rescue throw(:halt, "401 Unauthorized")
              end
          else
            session[:return_to] = request.fullpath
            redirect Plugins::AuthInABox::OPTIONS[:login_url]
            pass rescue throw :pass
          end
        end
        
        def admin_required
          return true if login_required && current_user.account_type == 'admin'
          redirect '/'
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