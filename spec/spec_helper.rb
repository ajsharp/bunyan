require 'rubygems'
require 'bundler'
Bundler.setup
Bundler.require :default, :test

require File.expand_path(File.dirname(__FILE__) + '/../lib/bunyan')
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

class DuckedMongo
end

Spec::Runner.configure do |config|

  config.before :each do
    mock_mongo_connection
  end

  def mock_mongo_connection
    @mock_collection = mock("Mongo Collection")
    @mock_connection = mock("Mongo Connection")
    @mock_database   = mock("Mongo Database", 
       :collection        => @mock_collection, 
       :create_collection => @mock_collection,
       :collection_names  => ['name 1'],
       :connection        => @mock_connection)
    @mock_connection.stub!(:db).and_return(@mock_database)
    Mongo::Connection.stub!(:new).and_return(@mock_connection)
    @mock_database
  end

  def other_fake_mongo
    #I want to check Mongo::Connection.stub.new is not called
    dm = DuckedMongo
    dm.stub!(:db).and_return(@mock_database)
    dm
  end

  def configure_test_db
    Bunyan::Logger.configure do |config|
      config.database   'bunyan_test'
      config.collection 'bunyan_test_log'
    end
  end
end
