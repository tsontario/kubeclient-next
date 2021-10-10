# frozen_string_literal: true

module K8y
  module REST
    module Auth
      module Providers
        class ProviderBase < AuthBase
          def configure_connection(connection)
            connection.request(:authorization, "Bearer", -> { TokenStore[connection.host] ||= token })
          end

          def regenerate_token!
            TokenStore[connection.host] = token
          end

          def token
            raise NotImplementedError, "subclasses of ProviderBase must implement #token"
          end
        end
      end
    end
  end
end
