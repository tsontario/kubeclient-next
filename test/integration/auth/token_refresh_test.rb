# frozen_string_literal: true

require "integration_test_helper"

module K8y
  module REST
    class TokenRefreshTest < IntegrationTestCase
      def setup
        # TODO: this is a hack; we shouldn't need to manually reset this here
        Auth::TokenStore["1.2.3.4"] = nil
      end

      def test_attempt_regenerate_token_on_401_request_then_uses_new_token_in_request
        Auth::Providers::GCP::ApplicationDefaultProvider.any_instance
          .expects(:token)
          .returns("first-token", "second-token")
          .times(2)

        config = Config.from_kubeconfig(fixture)
        client = Client.from_config(config)
        stubs = with_stubbed_client(client) do |stub|
          stub.get("https://1.2.3.4/", Authorization: "Bearer first-token") { |_env| [401, {}, "Unauthorized"] }
          stub.get("https://1.2.3.4/", Authorization: "Bearer second-token") { |_env| [200, {}, "bogus-response"] }
        end
        response = client.get("/", as: :raw)

        stubs.verify_stubbed_calls
        assert_equal("bogus-response", response.body)
      end

      def test_attempt_regenerate_token_on_401_request_then_uses_new_token_in_request_if_token_still_invalid
        Auth::Providers::GCP::ApplicationDefaultProvider.any_instance
          .expects(:token)
          .returns("first-token", "second-token")
          .times(2)

        config = Config.from_kubeconfig(fixture)
        client = Client.from_config(config)
        stubs = with_stubbed_client(client) do |stub|
          stub.get("https://1.2.3.4/", Authorization: "Bearer first-token") { |_env| [401, {}, "Unauthorized"] }
          stub.get("https://1.2.3.4/", Authorization: "Bearer second-token") { |_env| [401, {}, "Still unauthorized"] }
        end
        assert_raises(K8y::REST::UnauthorizedError) { client.get("/", as: :raw) }
        stubs.verify_stubbed_calls
      end

      private

      def with_stubbed_client(client, &block)
        stubs = Faraday::Adapter::Test::Stubs.new
        client.connection.connection.adapter(:test, stubs, &block)
        stubs
      end

      def fixture
        integration_fixture(File.join("auth", "token_refresh"))
      end
    end
  end
end
