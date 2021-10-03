# frozen_string_literal: true
module K8y
  module REST
    module Auth
      module Providers
        class FactoryTest < TestCase
          def test_from_auth_provider_raises_unnamed_provider_error_if_provider_name_not_present
            provider = {}
            assert_raises(Factory::UnnamedProviderError) { Factory.new.from_auth_provider(provider) }
          end

          def test_from_auth_provider_calls_gcp_factory_when_provider_name_is_gcp
            provider = { name: "gcp" }
            GCP::Factory.any_instance.expects(:from_auth_provider).with(provider)
            Factory.new.from_auth_provider(provider)
          end
        end
      end
    end
  end
end
