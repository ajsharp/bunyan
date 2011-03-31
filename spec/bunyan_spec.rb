require 'spec_helper'

describe Bunyan::Logger do
  before do
    Mongo::Connection.unstub!(:new)
    @logger = Bunyan::Logger.instance
    @mock_database = nil
  end

  it 'should have a connection' do
    configure_test_db
    @logger.connection.should be_instance_of Mongo::Connection
  end

  it 'should have a reference to the mongo db object' do
    configure_test_db
    @logger.db.should be_instance_of Mongo::DB
  end

  it 'should have a config hash' do
    Bunyan::Logger.config.should respond_to :[]
  end


  it 'should use the mongo c extension' do
    defined?(CBson::VERSION).should_not be_nil
  end
end

describe 'when a mongod instance is not running' do
  context "when initializing the bunyan setup" do
    before do
      Mongo::Connection.stub!(:new).and_raise(Mongo::ConnectionFailure)
    end

    it 'should not blow up' do
      lambda {
        Bunyan::Logger.configure do |c|
          c.database   'doesnt_matter'
          c.collection 'b/c mongod isnt running'
        end
      }.should_not raise_exception(Mongo::ConnectionFailure)
    end

    it 'should mark bunyan as disabled' do
      Bunyan::Logger.configure do |c|
        c.database   'doesnt_matter'
        c.collection 'b/c mongod isnt running'
      end
      Bunyan::Logger.should be_disabled
    end
  end

  context "when sending queries to Bunyan when a connection error occurs" do
    class Mongo::Connection
      attr_accessor :conn_fail

      def new_send_message_on_socket(*args)
        if conn_fail
          raise Mongo::ConnectionFailure
        else
          old_send_message_on_socket(*args)
        end
      end
    end

    before do
      Mongo::Connection.send(:alias_method, :old_send_message_on_socket, :send_message_on_socket)
      Mongo::Connection.send(:alias_method, :send_message_on_socket, :new_send_message_on_socket)
    end

    after do
      Mongo::Connection.send(:alias_method, :send_message_on_socket, :old_send_message_on_socket)
    end

    before do
      unstub_mongo
      configure_test_db
      Bunyan::Logger.connection.conn_fail = true
    end

    it "should not raise an exception" do
      lambda {
        Bunyan::Logger.count
      }.should_not raise_error(Mongo::ConnectionFailure)
    end

    it "should not raise an exception if a connection error occurs on multiple requests" do
      lambda {
        Bunyan::Logger.count
        Bunyan::Logger.count
      }.should_not raise_error(Mongo::ConnectionFailure)
    end

    it "should raise errors at the mongo level" do
      # This is really a test to make sure our crazy stubbing magic
      # above is working properly. It has nothing to do with actual
      # library behavior.
      lambda {
        db = Bunyan::Logger.db
        coll = db.collection('no_op_collection')
        coll.count
      }.should raise_error(Mongo::ConnectionFailure)
    end
  end
end

describe 'when initializing the collection' do
  before do
    @conn = mock_mongo_connection
    @logger = Bunyan::Logger.instance
    @logger.stub!(:connection).and_return(@conn)
  end

  it 'should create a new capped collection if the collection does not already exist' do
    @conn.should_receive(:create_collection).with('collection_1', :capped => true, :size => 52428800)
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


describe Bunyan::Logger, "#disabled?" do
  it "should return false if nothing is set" do
    Bunyan::Logger.configure do |config|
      config.database   'my_database'
      config.collection 'my_collection'
    end
    Bunyan::Logger.disabled?.should == false
  end
end

describe 'mongodb instance methods passed to a logger instance' do
  it 'should be passed through to the collection' do
    configure_test_db
    Bunyan::Logger.collection.should_receive(:count)
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
  it "should not send messages to the mongo collection" do
    @conn = mock_mongo_connection
    Bunyan::Logger.configure do |config|
      config.database   'bunyan_test'
      config.collection 'bunyan_test_log'
      config.disabled   true
    end
    %w(insert count find).each do |command|
      Bunyan::Logger.collection.should_not_receive(command)
      Bunyan::Logger.send command
    end
  end
end

# @NOTE: Some of these tests rely on other tests not modifying the mongo
# config object. This is not good, though much harder to achieve per-example
# independence when testing a singleton object.
describe 'when bunyan is not configured' do
  it 'should not try to send messages to mongo' do
    Bunyan::Logger.instance.stub!(:config).and_return(nil)
    %w(insert count find).each do |command|
      Bunyan::Logger.collection.should_not_receive(command)
      Bunyan::Logger.send command
    end
  end
end


