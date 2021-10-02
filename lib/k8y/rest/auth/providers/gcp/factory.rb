# frozen_string_literal: true

module K8y
  module REST
    module Auth
      module Providers
        module GCP
          class Factory
            Error = Class.new(Error)
            MisisngConfigError = Class.new(Error)

            class << self
              # see https://github.com/kubernetes/client-go/blob/master/plugin/pkg/client/auth/gcp/gcp.go#L58
              RECOGNIZED_KEYS = [:"access-token", :"cmd-args", :"cmd-path", :expiry, :"expiry-key", :"token-key"]

              def from_provider(provider)
                config = provider["config"]
                raise MissingConfigError unless config

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
end
