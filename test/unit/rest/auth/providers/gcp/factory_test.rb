# frozen_string_literal: true
module K8y
  module REST
    module Auth
      module Providers
        module GCP
          class FactoryTest < TestCase
            def test_from_auth_provider_returns_application_default_provider_if_cmd_path_not_present_in_config
              provider = {
                config: {},
              }
              ApplicationDefaultProvider.expects(:new)
              Factory.new.from_auth_provider(provider)
            end

            def test_from_auth_provider_returns_command_provider_if_cmd_path_present_in_config
              provider = {
                config: {
                  "cmd-path": "bogus/path",
                },
              }
              CommandProvider.expects(:new)
              Factory.new.from_auth_provider(provider)
            end
          end
        end
      end
    end
  end
end
