# frozen_string_literal: true

require_relative "gcp/factory"

module K8y
  module REST
    module Auth
      module Providers
        Error = Class.new(Error)

        class Factory
          UnnamedProviderError = Class.new(Error)
          def from_auth_provider(provider)
            case provider.name
            when "gcp"
              GCP::Factory.new.from_auth_provider(provider)
            when nil
              raise UnnamedProviderError
            end
          end
        end
      end
    end
  end
end
