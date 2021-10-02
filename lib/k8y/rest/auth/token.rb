# frozen_string_literal: true

require_relative "auth_base"

module K8y
  module REST
    module Auth
      class Token < AuthBase
        def initialize(token:)
          super()
          @token = token
        end

        def configure_connection(connection)
          connection.headers[:Authorization] = "Bearer #{token}"
        end

        private

        attr_reader :token
      end
    end
  end
end
