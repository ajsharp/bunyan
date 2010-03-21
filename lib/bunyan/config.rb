
module Bunyan
  class Logger

    class Config
      # used to hold all user-defined configuration options
      attr_accessor :collection, :database, :disabled

      def initialize
        @size     = 52428800
        @disabled = false
      end

      def [](meth)
        send(meth)
      end

      # First time called sets the database name. 
      # Otherwise, returns the database name.
      def database(db_name = nil)
        @database ||= db_name
      end
      alias_method :database=, :database

      # First time called sets the collection name. 
      # Otherwise, returns the collection name.
      # For the actual collection object returned by Mongo, see #db.
      def collection(coll = nil)
        @collection ||= coll
      end
      alias_method :collection=, :collection

      def disabled(dis = nil)
        @disabled ||= dis
      end
      alias_method :disabled=, :disabled

      # default size is 50 megabytes
      def size(new_size = nil)
        new_size.nil? ? @size : @size = new_size
      end
      alias_method :size=, :size
    end

  end
end
