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

            # #get_application_default actually returns a full oauth2 token payload
            # This gives us, among other things, a refresh token, that we should be
            # able to hold on to transparently keep client connections alive and
            # healthy.
            def token
              creds = Google::Auth.get_application_default(SCOPES)
              creds.apply({})
              creds.access_token
            end
          end
        end
      end
    end
  end
end
