require 'bunyan/configurable_methods'

module Bunyan
  class Logger

    class Config
      extend Bunyan::ConfigurableMethods
      configurable_methods :port, :host, :database, :collection, :disabled, :connection, :abort_on_failed_reconnect

      def initialize
        @size     = 52428800
        @disabled = false
      end

      def [](meth)
        send(meth)
      end

      def disabled?
        !!@disabled
      end

      def abort_on_failed_reconnect?
        !!@abort_on_failed_reconnect
      end

      # default size is 50 megabytes
      def size(new_size = nil)
        new_size.nil? ? @size : @size = new_size
      end
      alias_method :size=, :size
    end

  end
end
