# frozen_string_literal: true

require_relative "basic"
require_relative "token"
require_relative "providers/factory"

module K8y
  module REST
    module Auth
      class Factory
        def from_auth_info(auth_info)
          if auth_info.username && auth_info.password
            Basic.new(username: auth_info.username, password: auth_info.password)
          elsif auth_info.token
            Token.new(token: auth_info.token)
          elsif auth_info.auth_provider
            Providers::Factory.new.from_auth_provider(auth_info.auth_provider)
          else
            AuthBase.new
          end
        end
      end
    end
  end
end
