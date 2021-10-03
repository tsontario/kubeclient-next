# frozen_string_literal: true

require_relative "application_default_provider"
require_relative "command_provider"

module K8y
  module REST
    module Auth
      module Providers
        module GCP
          Error = Class.new(Error)

          class Factory
            MissingConfigError = Class.new(Error)

            def from_auth_provider(provider)
              config = provider[:config]
              raise MissingConfigError unless config

              # see https://github.com/kubernetes/client-go/blob/master/plugin/pkg/client/auth/gcp/gcp.go#L58
              if config[:"cmd-path"]
                CommandProvider.new(
                  access_token: config[:"access-token"],
                  cmd_args: config[:"cmd-args"],
                  cmd_path: config[:"cmd-path"],
                  expiry: config[:expiry],
                  expiry_key: config[:"expiry-key"],
                  token_key: config[:"token-key"]
                )
              else
                ApplicationDefaultProvider.new
              end
            end
          end
        end
      end
    end
  end
end
