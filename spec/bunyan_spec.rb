require 'spec/spec_helper'

describe Bunyan::Logger do

  before do
    @conn = mock_mongo_connection
    @logger = Bunyan::Logger.instance
    @logger.stub!(:connection).and_return(@conn)
  end

  it 'should have a connection' do
    @logger.should respond_to :connection
  end

  it 'should have a collection' do
    @logger.should respond_to :collection
  end

  it 'should have a config hash' do
    @logger.config.should be_a Hash
  end

  it 'should create a new capped collection if the collection does not already exist' do
    @conn.should_receive(:create_collection).with('collection_1', :capped => true)
    @conn.stub!(:collection_names).and_return([])
    Bunyan::Logger.configure do |config|
      config.database   'database_1'
      config.collection 'collection_1'
    end
  end

  it 'should not create a new collection if one already exists by that name' do
    @conn.should_not_receive(:create_collection)
    @conn.collection_names.should_receive(:include?).with('collection_1').and_return(true)
    Bunyan::Logger.configure do |config|
      config.database   'database_1'
      config.collection 'collection_1'
    end
  end

end

describe 'the required config options' do
  it 'should raise an error if a db name is not provided' do
    lambda {
      Bunyan::Logger.configure do |c|
        c.collection 'collection_without_database'
      end
    }.should raise_exception(Bunyan::Logger::InvalidConfigurationError, 'Error! Please provide a database name.')
  end

  it 'should raise an error if a db collection is not provided' do
    lambda {
      Bunyan::Logger.configure do |c|
        c.database 'db_without_collection'
      end
    }.should raise_exception(Bunyan::Logger::InvalidConfigurationError, 'Error! Please provide a collection name.')
  end
end

describe 'bunyan logger configuration' do
  describe 'setting config values' do
    before do
      Bunyan::Logger.configure do |c|
        c.database   'database2'
        c.collection 'collection2'
      end
    end

    it 'should allow setting of the database' do
      Bunyan::Logger.database.should == 'database2'
    end

    it 'shoudl allow setting of the collection name' do
      Bunyan::Logger.collection.should == 'collection2'
    end
  end

  describe 'the optional config options' do
    it 'should allow the user to mark bunyan as disabled' do
      Bunyan::Logger.configure do |c|
        c.database   'test_db'
        c.collection 'test_collection'
        c.disabled   true
      end
      Bunyan::Logger.should be_disabled
    end
  end

  describe "when the disabled flag is set" do
    it 'should not create a new logger instance' do
      Bunyan::Logger.should_not_receive(:initialize_connection)
      Bunyan::Logger.configure do |c|
        c.database   'test_db'
        c.collection 'test_collection'
        c.disabled   true
      end
    end
  end
end

describe Bunyan::Logger, "#disabled?" do
  it "should return false if nothing is set" do
    Bunyan::Logger.configure do |config|
      config.database   'my_database'
      config.collection 'my_collection'
    end
    Bunyan::Logger.disabled?.should == false
  end
end

describe 'the database getter' do
  it 'should allow setting of the database' do
    Bunyan::Logger.configure do |config|
      config.database   'my_database'
      config.collection 'my_collection'
    end
    Bunyan::Logger.instance.database.should == 'my_database'
  end
end

describe 'mongodb instance methods passed to a logger instance' do
  it 'should be passed through to the collection' do
    configure_test_db
    Bunyan::Logger.db.should_receive(:count)
    Bunyan::Logger.count
  end
end

describe 'alternate configuration syntax' do
  it 'should allow a user to set config options with traditional setters' do
    Bunyan::Logger.configure do |config|
      config.database = 'some_database'
      config.collection = 'some_collection'
    end
    Bunyan::Logger.config[:database].should == 'some_database'
  end
end

describe 'when bunyan is disabled' do
  before do
    @conn = mock_mongo_connection
    Bunyan::Logger.configure do |config|
      config.database   'bunyan_test'
      config.collection 'bunyan_test_log'
      config.disabled   true
    end
  end

  it "should not send messages to the mongo collection" do
    %w(insert count find).each do |command|
      Bunyan::Logger.db.should_not_receive(command)
      Bunyan::Logger.send command
    end
  end
end

describe 'when bunyan is not configured' do
  it 'should not try to send messages to mongo' do
    Bunyan::Logger.instance.stub!(:configured?).and_return(false)
    Bunyan::Logger.should_not be_configured
    Bunyan::Logger.should_not be_disabled
    %w(insert count find).each do |command|
      Bunyan::Logger.db.should_not_receive(command)
      Bunyan::Logger.send command
    end
  end
end

describe 'the mongo configuration state' do
  it 'should not be configured by default' do
    Bunyan::Logger.should_not be_configured
  end

  it 'should be configured after being configured' do
    Bunyan::Logger.configure do |config|
      config.database   'bunyan_test'
      config.collection 'bunyan_test_log'
    end

    Bunyan::Logger.should be_configured
  end
end
