#           NAME: initializer
#        VERSION: 1.0
#         AUTHOR: Peter Cooper [ http://www.rubyinside.com/ github:peterc twitter:peterc ]
#    DESCRIPTION: Sinatra library to perform initialization functions - oriented around DataMapper use
#  COMPATIBILITY: All, in theory - tested on Hoboken
#        LICENSE: Use for what you want
#
#   INSTRUCTIONS: 
#                 1. Ensure _this_ file is lib/initializer.rb within your app's directory structure
#                 2. Read through and customize this file to your taste and your app's requirements
#                 3. Add require 'lib/initializer' to your Sinatra app
 
 
# Add the current app's /lib folder to the load path for convenience
$:.unshift('lib')
 
# Load any gems required for the app - database drivers, etc..
require 'rubygems'
require 'datamapper'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'fileutils'
require 'haml'

# Establish base directory names  
  DATABASE_DIR = File.join(APP_ROOT, "db")
 
# If the db directory (for SQLite databases) doesn't exist, create it
  FileUtils.mkdir(DATABASE_DIR) unless File.directory?(DATABASE_DIR)
 
# Establish environments and connect to database
  configure :development do
    # Turn on logging for DataMapper when in development environment
    DataMapper::Logger.new(STDOUT, :debug)
    DataMapper.setup(:default, "sqlite3://" + File.join(DATABASE_DIR, "development.db"))
    puts File.join(DATABASE_DIR, "db", "development.db")
  end
  
  configure :production do
    DataMapper.setup(:default, ENV['DATABASE_URL'] || ("sqlite3://" + File.join(DATABASE_DIR, "production.db")))
  end
  
  configure :test do
    DataMapper.setup(:default, "sqlite3://" + File.join(DATABASE_DIR, "test.db"))
  end
  
 
# Load plugins, if any
  Dir[APP_ROOT + '/plugins/**/*.rb'].each { |plugin| load plugin } if File.directory?(File.join(APP_ROOT, "plugins"))
 
# Load models, if any
  Dir[APP_ROOT + '/models/**/*.rb'].each { |model| load model } if File.directory?(File.join(APP_ROOT, "models"))
 
# Upgrade database schema from models
  DataMapper.auto_upgrade!
 
# Enable sessions
  enable :sessions