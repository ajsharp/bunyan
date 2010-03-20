require 'rubygems'

#gem 'mongo_ext'

require 'mongo'
require 'singleton'

module Bunyan
  class Logger
    include Singleton

    class InvalidConfigurationError < RuntimeError; end

    attr_reader :db, :connection, :config, :configured

    # Bunyan::Logger.configure do |config|
    #   # required options
    #   config.database   'bunyan_logger'
    #   config.collection 'development_log'
    # end
    def configure(&block)
      @config = {}

      yield self

      ensure_required_options_exist
      initialize_connection unless disabled?
      @configured = true
    end

    def configured?
      !!@configured
    end

    # First time called sets the database name. 
    # Otherwise, returns the database name.
    def database(db_name = nil)
      @config[:database] ||= db_name
    end
    alias_method :database=, :database

    # First time called sets the collection name. 
    # Otherwise, returns the collection name.
    # For the actual collection object returned by Mongo, see #db.
    def collection(coll = nil)
      @config[:collection] ||= coll
    end
    alias_method :collection=, :collection

    def disabled(dis = nil)
      @config[:disabled] ||= dis
    end
    alias_method :disabled=, :disabled

    def disabled?
      !!disabled
    end

    def method_missing(method, *args, &block)
      begin
        db.send(method, *args) if database_is_usable?
      rescue
        super(method, *args, &block)
      end
    end

    # Pass all missing class methods to the singleton instance
    def self.method_missing(method, *args, &block)
      Logger.instance.send(method, *args, &block)
    end

    private
      def initialize_connection
        @connection  = Mongo::Connection.new.db(database)
        @db          = retrieve_or_initialize_collection(collection)
      end

      def database_is_usable?
         configured? && !disabled?
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
