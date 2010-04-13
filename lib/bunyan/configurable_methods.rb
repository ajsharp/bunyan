module Bunyan
  module ConfigurableMethods
    private
      def configurable_method(method_name)
        class_eval %Q{
          def #{method_name}(local_#{method_name} = nil)
            @#{method_name} ||= local_#{method_name}
          end
          alias_method :#{method_name}=, :#{method_name}
        }
      end

      def configurable_methods(*methods)
        methods.each { |method| configurable_method(method) }
      end
  end
end
