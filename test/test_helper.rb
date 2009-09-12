require 'rubygems'
$:.unshift File.join(File.dirname(__FILE__), '..', 'vendor', 'sinatra', 'lib')
require 'sinatra'
require 'rack/test'

set :environment, :test

require 'test/unit'
require 'mocha'
require 'shoulda'
require "webrat/sinatra"
require 'sham'
require 'faker'
require 'machinist/data_mapper'

require File.join(File.dirname(__FILE__), '..', 'lib', 'ecomo_wizzard.rb')
require File.expand_path(File.dirname(__FILE__) + "/blueprints")

Webrat.configure do |config|
  config.mode = :sinatra
  config.open_error_files = false
end

module TestHelper
  
  include Webrat::Methods
  include Webrat::Matchers
  
  def app
    EcomoWizzard.tap { |app| app.set :environment, :test }
  end
  
  def body
    last_response.body
  end
  
  def status
    last_response.status
  end
  
  include Rack::Test::Methods
  
end

Test::Unit::TestCase.send(:include, TestHelper)
