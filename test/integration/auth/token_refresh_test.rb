# frozen_string_literal: true
require "integration_test_helper"

module K8y
  module REST
    class TokenRefreshTest < IntegrationTestCase
      def test_attempt_regenerate_token_on_401_request_then_raise_401_if_token_still_invalid
        config = Config.from_kubeconfig(fixture)
        client = Client.from_config(config)
        # TODO...
      end

      private

      def fixture
        integration_fixture(File.join("auth", "token_refresh"))
      end
    end
  end
end
