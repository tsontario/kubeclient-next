# frozen_string_literal: true

require "googleauth"
require "json"
require "open3"
require "shellwords"

require_relative "../provider_base"

module K8y
  module REST
    module Auth
      module Providers
        module GCP
          class CommandProvider < ProviderBase
            # TODO: this is a shameless copy of abonas/kubeclient. It's worth it to build this from scratch,
            # if only for the better understanding that comes along with it
            def initialize(cmd_path:, access_token: nil, cmd_args: nil, expiry: nil, expiry_key: nil, token_key: nil)
              super
              @access_token = access_token
              @cmd_args = cmd_args
              @cmd_path = cmd_path
              @expiry = expiry
              @expiry_key = expiry_key
              @token_key = token_key
            end

            private

            def token
              out, err, st = Open3.capture3(cmd, *args.split)

              raise "exec command failed: #{err}" unless st.success?

              extract_token(out, token_key)
            end

            def extract_token(output, key)
              path =
                key
                  .gsub(/\A{(.*)}\z/, "\\1") # {.foo.bar} -> .foo.bar
                  .sub(/\A\./, "") # .foo.bar -> foo.bar
                  .split(".")
              JSON.parse(output).dig(*path)
            end
          end
        end
      end
    end
  end
end
