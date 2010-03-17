require 'rubygems'

#gem 'mongo_ext'

require 'mongo'
require 'singleton'

module Bunyan
  class Logger
    include Singleton

    class InvalidConfigurationError < RuntimeError; end

    attr_reader :db, :connection

    # Bunyan::Logger.configure do |config|
    #   # required options
    #   config.database   'bunyan_logger'
    #   config.collection 'development_log'
    # end
    def configure(&block)
      @config = {}
      yield self
      ensure_required_options_exist
      initialize_connection
    end

    # First time called sets the database name. 
    # Otherwise, returns the database name.
    def database(db_name = nil)
      @config[:database] ||= db_name
    end

    # First time called sets the collection name. 
    # Otherwise, returns the collection name.
    # For the actual collection object returned by Mongo, see #db.
    def collection(coll = nil)
      @config[:collection] ||= coll
    end

    def disabled(dis = nil)
      @config[:disabled] ||= dis
    end

    def disabled?
      disabled
    end

    def method_missing(method, *args, &block)
      begin
        db.send(method, *args)
      rescue
        super(method, *args, &block)
      end
    end

    def self.method_missing(method, *args, &block)
      Logger.instance.send(method, *args, &block)
    end

    private
      def initialize_connection
        @connection  = Mongo::Connection.new.db(database)
        @db          = retrieve_or_initialize_collection(collection)
      end

      def ensure_required_options_exist
        raise InvalidConfigurationError, 'Error! Please provide a database name.'   unless database
        raise InvalidConfigurationError, 'Error! Please provide a collection name.' unless collection
      end

      def retrieve_or_initialize_collection(collection_name)
        if collection_exists?(collection_name)
          connection.collection(collection_name)
        else
          connection.create_collection(collection_name, :capped => true)
        end
      end

      def collection_exists?(collection_name)
        connection.collection_names.include? collection_name
      end
  end
end
