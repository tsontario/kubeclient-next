# frozen_string_literal: true

require_relative "auth_base"

module K8y
  module REST
    module Auth
      class Basic < AuthBase
        def initialize(username:, password:)
          super()
          @username = username
          @password = password
        end

        def configure_connection(connection)
          connection.basic_auth(username, password)
        end

        private

        attr_reader :username, :password
      end
    end
  end
end
