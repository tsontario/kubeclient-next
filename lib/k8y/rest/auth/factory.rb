# frozen_string_literal: true

require_relative "basic"
require_relative "token"
require_relative "providers/factory"

module K8y
  module REST
    module Auth
      class Factory
        class << self
          def new_from_kubeconfig_auth_info(auth_info)
            if auth_info.username && auth_info.password
              Basic.new(username: auth_info.username, password: auth_info.password)
            elsif auth_info.token
              Token.new(token: token)
            elsif auth_info.auth_provider
              Providers::Factory.from_provider(auth_info[AUTH_PROVIDER_KEY])
            else
              AuthBase.new
            end
          end
        end
      end
    end
  end
end
