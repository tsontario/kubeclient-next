# frozen_string_literal: true

require_relative "basic"
require_relative "token"
require_relative "providers/factory"

module K8y
  module REST
    module Auth
      class Factory
        def from_auth_info(auth_info)
          case auth_info.strategy
          when :basic
            Basic.new(username: auth_info.username, password: auth_info.password)
          when :token
            Token.new(token: auth_info.token)
          when :auth_provider
            Providers::Factory.new.from_auth_provider(auth_info.auth_provider)
          else
            AuthBase.new
          end
        end
      end
    end
  end
end
