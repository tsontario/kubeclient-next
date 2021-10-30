# frozen_string_literal: true

module K8y
  module REST
    class FaradaySettings
      class << self
        attr_reader :config_lambda

        def configure_connection(connection)
          config_lambda&.call(connection)
        end

        def with_connection(&block)
          @config_lambda = ->(connection) { yield(connection) }
        end
      end
    end
  end
end
