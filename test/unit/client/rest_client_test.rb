# frozen_string_literal: true

require "test_helper"

module KubeclientNext
  module Client
    class RESTClientTest < TestCase
      def setup
        super
        @config = config_fixture
        RESTClient.any_instance.stubs(:hardcoded_auth)
      end

      def test_get_root_path
        with_mock_connection(method: :get, path: "https://1.2.3.4") do
          rest_client = RESTClient.new(config: @config, context: @config.current_context)
          rest_client.get
        end
      end

      def test_get_path
        with_mock_connection(method: :get, path: "https://1.2.3.4/core/v1") do
          rest_client = RESTClient.new(config: @config, context: @config.current_context, path: "core/v1")
          rest_client.get
        end
      end

      def test_get_path_and_subpath
        with_mock_connection(method: :get, path: "https://1.2.3.4/core/v1/configmaps") do
          rest_client = RESTClient.new(config: @config, context: @config.current_context, path: "core/v1")
          rest_client.get("configmaps")
        end
      end

      def test_get_root_path_and_subpath
        with_mock_connection(method: :get, path: "https://1.2.3.4/subpath") do
          rest_client = RESTClient.new(config: @config, context: @config.current_context)
          rest_client.get("subpath")
        end
      end

      def test_get_transparently_handles_slashes_in_path_param
        with_mock_connection(method: :get, path: "https://1.2.3.4/path/subpath") do
          rest_client = RESTClient.new(config: @config, context: @config.current_context, path: "/path/")
          rest_client.get("subpath")
        end
      end

      def test_post_path
        path = "https://1.2.3.4/core/v1/fakeresource"
        data = { fake: "data" }
        headers = { "Content-Type" => "application/json" }
        with_mock_connection(method: :post, path: path, data: data, headers: headers) do
          rest_client = RESTClient.new(config: @config, context: @config.current_context, path: "core/v1")
          rest_client.post("fakeresource", data: data, headers: headers)
        end
      end

      def test_put_path
        path = "https://1.2.3.4/core/v1/fakeresource"
        data = { fake: "data" }
        with_mock_connection(method: :put, path: path, data: data, headers: {}) do
          rest_client = RESTClient.new(config: @config, context: @config.current_context, path: "core/v1")
          rest_client.put("fakeresource", data: data)
        end
      end

      def test_patch_path_json_patch
        path = "https://1.2.3.4/core/v1/fakeresource"
        data = [{ "op" => "add", "path" => "/fake/path", "value" => "test" }]
        headers = { "Content-Type" => "application/json-patch+json" }
        with_mock_connection(method: :patch, path: path, data: data, headers: headers) do
          rest_client = RESTClient.new(config: @config, context: @config.current_context, path: "core/v1")
          rest_client.patch("fakeresource", strategy: :json, data: data, headers: headers)
        end
      end

      def test_delete_path
        with_mock_connection(method: :delete, path: "https://1.2.3.4/core/v1/fakeresource") do
          rest_client = RESTClient.new(config: @config, context: @config.current_context, path: "core/v1")
          rest_client.delete("fakeresource")
        end
      end

      private

      def with_mock_connection(method:, path: nil, **kwargs)
        mock_connection = mock.responds_like_instance_of(Faraday::Connection)
        mock_connection.expects(method).with(URI.parse(path), *kwargs.values)
        RESTClient.any_instance.stubs(:connection).returns(mock_connection)
        yield
      end
    end
  end
end
