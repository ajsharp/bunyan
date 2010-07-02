require 'spec_helper'

describe Bunyan::Logger::Config do
  before do
    @config = Bunyan::Logger::Config.new
  end

  it 'should have a collection' do
    @config.should respond_to :collection
  end
end

describe Bunyan::Logger::Config, 'collection size' do
  it 'should default to 50 megabytes' do
    # configure_test_db
    config = Bunyan::Logger::Config.new
    config.size.should == 52428800
  end

  it 'should all the user to set the collection size' do
    Bunyan::Logger.configure do |c|
      c.database   'bunyan_test_log'
      c.collection 'configured_size'
      c.size       100_000_000
    end

    Bunyan::Logger.config[:size].should == 100_000_000
  end
end

describe Bunyan::Logger::Config, 'when setting the collection size' do
  it 'should never set the size to nil' do
    @config = Bunyan::Logger::Config.new
    @config.size nil
    @config.size.should == 52428800
  end

  it 'should override the default value' do
    @config = Bunyan::Logger::Config.new
    @config.size 1010
    @config.size.should == 1010
  end
end

describe Bunyan::Logger::Config, 'when getting the collection size' do
  it 'should return the collection size' do
    Bunyan::Logger.configure do |c|
      c.database   'test_db'
      c.collection 'test_collection'
      c.size       2929
    end

    Bunyan::Logger.config.size.should == 2929
  end
end

describe Bunyan::Logger::Config, 'alternate method invocation syntax' do
  it 'should act like a hash' do
    config = Bunyan::Logger::Config.new
    config.size 10
    config.should_receive(:size).and_return(10)
    config[:size].should == 10
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
      Bunyan::Logger.config.database.should == 'database2'
    end

    it 'shoudl allow setting of the collection name' do
      Bunyan::Logger.config.collection.should == 'collection2'
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

describe Bunyan::Logger::Config, "#disabled?" do
  before :each do
    @config = Bunyan::Logger::Config.new
  end

  it 'should be false if @disabled is nil' do
    @config.disabled = nil
    @config.should_not be_disabled
  end

  it 'should be true if @disabled is true' do
    @config.disabled = true
    @config.should be_disabled
  end

  it 'should be false if @isabled is false' do
    @config.disabled = false
    @config.should_not be_disabled
  end
end

describe 'when we configure a remote host' do
  def configure_with_remote_host
    Bunyan::Logger.configure do |c|
      c.host       'some.remote.host'
      c.database   'test_db'
      c.collection 'test_collection'
    end
  end

  it 'should attempt to connect to the remote host' do
    Mongo::Connection.should_receive(:new).with('some.remote.host', nil)
    configure_with_remote_host
  end

  it 'should set the host config option' do
    configure_with_remote_host
    Bunyan::Logger.config.host.should == 'some.remote.host'
  end
end

describe 'when we configure a port' do
  def configure_with_remote_port
    Bunyan::Logger.configure do |c|
      c.host       'some.remote.host'
      c.port       '20910'
      c.database   'test_db'
      c.collection 'test_collection'
    end
  end

  it 'should attempt to connect to a remote port' do
    Mongo::Connection.should_receive(:new).with('some.remote.host', '20910')
    configure_with_remote_port
  end

  it 'should set the port config option' do
    configure_with_remote_port
    Bunyan::Logger.config.port.should == '20910'
  end
end

describe 'when we set a connection' do

  def configure_with_connection
    Bunyan::Logger.configure do |c|
      c.connection = other_fake_mongo
      c.port       '20910'
      c.database   'test_db'
      c.collection 'test_collection'
    end
  end

  it 'should not set a connection based on other params' do
    Mongo::Connection.should_not_receive(:new)
    configure_with_connection
  end

  it 'should set the db field' do
    Mongo::Connection.should_not_receive(:new)
    configure_with_connection
    Bunyan::Logger.db.should eql(@mock_database)
  end
  
end

