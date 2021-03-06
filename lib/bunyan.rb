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

    # @example Configuring bunyan
    #   Bunyan::Logger.configure do
    #     # required options
    #     database   'bunyan_logger'
    #     collection 'development_log'
    #
    #     # optional options
    #     disabled true
    #     size 52428800 # 50.megabytes in Rails
    #   end
    def configure(&block)
      @config = Logger::Config.new
      @config.abort_on_failed_reconnect = false

      # provide legacy support for old configuration syntax
      (block.arity > 0) ? yield(@config) : @config.instance_eval(&block)

      ensure_required_options_exist
      initialize_connection unless disabled?
      @configured = true
    end

    def configured?
      !!@configured
    end

    def disabled?
      # @TODO: Refactor this. Yuck.
      config.nil? || (!config.nil? && config.disabled?)
    end

    def method_missing(method, *args, &block)
      begin
        collection.send(method, *args) if database_is_usable?
      rescue Mongo::ConnectionFailure
        # At this point, the problem may be that the server was restarted
        # and we have stale connection object. The mongo ruby driver will
        # handle automatically handling a reconnect, and will issue a fresh
        # connection object if it can obtain one. In which case, let's try
        # the query again.
        begin
          collection.send(method, *args, &block) if database_is_usable?
        rescue Mongo::ConnectionFailure => e
          # Ok, we're having real connection issues. The mongod server is likely
          # down. We still may want to fail silently, because bunyan is mostly a support
          # library, and we wouldn't want exceptions to bubble up just b/c the
          # mongod server is down. If it were the core datastore, then we probably
          # would want it to bubble up.
          #
          # If you for some reason you do want error to bubble up, set the
          # `abort_on_failed_reconnect` config option to true.

          raise e if config.abort_on_failed_reconnect?
        end
      end
    end

    # Pass all missing class methods to the singleton instance
    def self.method_missing(method, *args, &block)
      Logger.instance.send(method, *args, &block)
    end

    private
      def initialize_connection
        begin
          if (config.connection)
            @connection = config.connection
            @db = @connection.db
          else
            @db = Mongo::Connection.new(config.host, config.port).db(config.database)
            @connection = @db.connection
          end
          @collection = retrieve_or_initialize_collection(config.collection)
        rescue Mongo::ConnectionFailure => ex
          # @TODO: I don't like how I'm overloading @config.disabled
          # for user disabling and error disabling
          @config.disabled = true
          $stderr.puts 'An error occured trying to connect to MongoDB!'
        end
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
          db.collection(collection_name)
        else
          db.create_collection(collection_name, :capped => true, :size => config.size)
        end
      end

      def collection_exists?(collection_name)
        db.collection_names.include? collection_name
      end

  end
end
