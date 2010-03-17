Bundler.setup
Bundler.require :default, :test

require File.expand_path(File.dirname(__FILE__) + '/../lib/bunyan')
$LOAD_PATH.unshift File.expand_path(__FILE__)

Spec::Runner.configure do |config|

  config.after :each do
    cleanup_bunyan_config
  end

  config.before :each do
    mock_mongo_connection
  end

  def mock_mongo_connection
    @mock_collection = mock("Mongo Collection")
    @mock_database   = mock("Mongo Database", 
       :collection        => @mock_collection, 
       :create_collection => @mock_collection,
       :collection_names  => ['name 1'])
    @mock_connection = mock("Mongo Connection", :db => @mock_database)
    Mongo::Connection.stub!(:new).and_return(@mock_connection)
    @mock_database
  end

  def cleanup_bunyan_config
    Bunyan::Logger.instance_variable_set(:@database, nil)
    Bunyan::Logger.instance_variable_set(:@collection, nil)
    Bunyan::Logger.instance_variable_set(:@db, nil)
  end
end
