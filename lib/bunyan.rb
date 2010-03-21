require 'rubygems'
require 'mongo'
require 'singleton'

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'bunyan/config'

module Bunyan
  class Logger
    include Singleton

    class InvalidConfigurationError < RuntimeError; end

    attr_reader :db, :connection, :collection, :config

    # Bunyan::Logger.configure do |config|
    #   # required options
    #   config.database   'bunyan_logger'
    #   config.collection 'development_log'
    #
    #   # optional options
    #   config.disabled true
    #   config.size 52428800 # 50.megabytes in Rails
    # end
    def configure(&block)
      @config = Logger::Config.new

      yield @config

      ensure_required_options_exist
      initialize_connection unless disabled?
      @configured = true
    end

    def configured?
      @configured
    end

    def disabled?
      !!config.disabled
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
        @db         = Mongo::Connection.new.db(config.database)
        @connection = @db.connection
        @collection = retrieve_or_initialize_collection(config.collection)
      end

      def database_is_usable?
         configured? && !disabled?
      end

      def ensure_required_options_exist
        raise InvalidConfigurationError, 'Error! Please provide a database name.'   unless config.database
        raise InvalidConfigurationError, 'Error! Please provide a collection name.' unless config.collection
      end

      def retrieve_or_initialize_collection(collection_name)
        if collection_exists?(collection_name)
          connection.collection(collection_name)
        else
          db.create_collection(collection_name, :capped => true, :size => config.size)
        end
      end

      def collection_exists?(collection_name)
        connection.collection_names.include? collection_name
      end

  end
end
