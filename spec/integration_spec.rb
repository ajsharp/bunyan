require 'spec_helper'

describe 'making a mongodb connection with the new configuration syntax' do
  def configure_db_with_new_syntax
    Bunyan::Logger.configure do
      database   'bunyan_integration_db'
      collection 'test_integration'
    end
  end
  
  before do
    Mongo::Connection.unstub!(:new)
    configure_db_with_new_syntax
    @params = {:request_uri => '/', :response_code => 200}
  end
    
  it 'should allow inserting documents' do
    Bunyan::Logger.insert(@params).should be_instance_of BSON::ObjectId
  end
  
  it 'should allow querying documents' do
    Bunyan::Logger.insert(@params)
    Bunyan::Logger.find(@params).count.should == 1
  end
end

describe 'making a mongodb connection with the old configuration syntax' do
  def configure_db_with_old_syntax
    Bunyan::Logger.configure do |c|
      c.database   'bunyan_integration_db'
      c.collection 'test_integration'
    end
  end
  
  before do
    Mongo::Connection.unstub!(:new)
    configure_db_with_old_syntax
    @params = {:request_uri => '/', :response_code => 200}
  end
    
  it 'should allow inserting documents' do
    Bunyan::Logger.insert(@params).should be_instance_of BSON::ObjectId
  end
  
  it 'should allow querying documents' do
    Bunyan::Logger.insert(@params)
    Bunyan::Logger.find(@params).count.should == 1
  end
end
