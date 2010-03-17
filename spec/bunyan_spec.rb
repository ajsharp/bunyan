require 'spec_helper'

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
    before do
    end

    it 'should not create a new logger instance' do
      Bunyan::Logger.should_not_receive(:new)
      Bunyan::Logger.configure do |c|
        c.database   'test_db'
        c.collection 'test_collection'
        c.disabled   true
      end
    end
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
    Bunyan::Logger.db.should_receive(:count)
    Bunyan::Logger.count
  end
end
