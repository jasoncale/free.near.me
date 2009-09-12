require File.expand_path(File.join(File.dirname(__FILE__), 'base'))
Dir[APP_ROOT + '/remote_sources/**/*.rb'].each { |model| load model } 