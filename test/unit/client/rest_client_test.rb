# frozen_string_literal: true

require "test_helper"

module KubeclientNext
  module Client
    class RESTClientTest < KubeclientNext::TestCase
      def setup
        super
        @config = config_fixture
        RESTClient.any_instance.stubs(:hardcoded_auth)
      end

      def test_get_root_path
        with_mock_connection(expected_path: "https://1.2.3.4") do
          rest_client = RESTClient.new(config: @config, context: @config.current_context)
          rest_client.get
        end
      end

      def test_get_path
        with_mock_connection(expected_path: "https://1.2.3.4/core/v1") do
          rest_client = RESTClient.new(config: @config, context: @config.current_context, path: "core/v1")
          rest_client.get
        end
      end

      def test_get_path_and_subpath
        with_mock_connection(expected_path: "https://1.2.3.4/core/v1/configmaps") do
          rest_client = RESTClient.new(config: @config, context: @config.current_context, path: "core/v1")
          rest_client.get("configmaps")
        end
      end

      def test_get_root_path_and_subpath
        with_mock_connection(expected_path: "https://1.2.3.4/subpath") do
          rest_client = RESTClient.new(config: @config, context: @config.current_context)
          rest_client.get("subpath")
        end
      end

      def test_get_transparently_handles_slashes_in_path_param
        with_mock_connection(expected_path: "https://1.2.3.4/path/subpath") do
          rest_client = RESTClient.new(config: @config, context: @config.current_context, path: "/path/")
          rest_client.get("subpath")
        end
      end

      private

      def with_mock_connection(expected_path: nil)
        mock_connection = mock.responds_like_instance_of(Faraday::Connection)
        mock_connection.expects(:get).with(URI.parse(expected_path))
        RESTClient.any_instance.stubs(:connection).returns(mock_connection)
        yield
      end
    end
  end
end
