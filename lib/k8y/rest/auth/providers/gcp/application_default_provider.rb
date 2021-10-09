# frozen_string_literal: true

require "googleauth"

require_relative "../provider_base"

module K8y
  module REST
    module Auth
      module Providers
        module GCP
          class ApplicationDefaultProvider < ProviderBase
            SCOPES = [
              "https://www.googleapis.com/auth/cloud-platform",
              "https://www.googleapis.com/auth/userinfo.email",
            ]

            def configure_connection(connection)
              host = URI(connection.host).hostname
              TokenStore[host] ||= token
              connection.headers[:Authorization] = "Bearer #{TokenStore[host]}"
            end

            def generate_token!
              token(force: true)
            end

            private

            def token(force: false)
              return @token if @token.present? && !force

              creds = Google::Auth.get_application_default(SCOPES)
              creds.apply({})
              @token = creds.access_token
            end
          end
        end
      end
    end
  end
end
