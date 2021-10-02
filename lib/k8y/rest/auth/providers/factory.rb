# frozen_string_literal: true

require_relative "gcp/factory"

module K8y
  module REST
    module Auth
      module Providers
        class Factory
          def from_provider(provider)
            case provider["name"]
            when "gcp"
              GCP::Factory.from_provider(provider)
            when nil
              raise UnnamedProviderError
            end
          end
        end
      end
    end
  end
end
