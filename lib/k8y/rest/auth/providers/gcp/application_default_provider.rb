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

            # TODO: model refresh tokens, automated refresh, etc.
            def token
              authorization = Google::Auth.get_application_default(SCOPES)
              authorization.apply({})
              authorization.access_token
            end
          end
        end
      end
    end
  end
end
