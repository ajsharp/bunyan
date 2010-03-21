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
  it 'should return the collection size'
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

