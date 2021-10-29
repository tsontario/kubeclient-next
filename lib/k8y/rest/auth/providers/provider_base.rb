# frozen_string_literal: true

module K8y
  module REST
    module Auth
      module Providers
        class ProviderBase < AuthBase
          def configure_connection(connection)
            connection.request(:authorization, "Bearer", -> { TokenStore[connection.host] ||= token })
          end

          def generate_token!(connection)
            TokenStore[connection.host] = token
          end

          private

          def token
            raise NotImplementedError, "subclasses of ProviderBase must implement #token"
          end
        end
      end
    end
  end
end
