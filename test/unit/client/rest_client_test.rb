# frozen_string_literal: true

require "test_helper"

module K8y
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
          rest_client.get(as: :raw)
        end
      end

      def test_get_path
        with_mock_connection(method: :get, path: "https://1.2.3.4/core/v1") do
          rest_client = RESTClient.new(config: @config, context: @config.current_context, path: "core/v1")
          rest_client.get(as: :raw)
        end
      end

      def test_get_path_and_subpath
        with_mock_connection(method: :get, path: "https://1.2.3.4/core/v1/configmaps") do
          rest_client = RESTClient.new(config: @config, context: @config.current_context, path: "core/v1")
          rest_client.get("configmaps", as: :raw)
        end
      end

      def test_get_root_path_and_subpath
        with_mock_connection(method: :get, path: "https://1.2.3.4/subpath") do
          rest_client = RESTClient.new(config: @config, context: @config.current_context)
          rest_client.get("subpath", as: :raw)
        end
      end

      def test_get_transparently_handles_slashes_in_path_param
        with_mock_connection(method: :get, path: "https://1.2.3.4/path/subpath") do
          rest_client = RESTClient.new(config: @config, context: @config.current_context, path: "/path/")
          rest_client.get("subpath", as: :raw)
        end
      end

      def test_post_path
        path = "https://1.2.3.4/core/v1/fakeresource"
        data = { fake: "data" }
        headers = { "Content-Type" => "application/json" }
        with_mock_connection(method: :post, path: path, data: data, headers: headers) do
          rest_client = RESTClient.new(config: @config, context: @config.current_context, path: "core/v1")
          rest_client.post("fakeresource", data: data, headers: headers, as: :raw)
        end
      end

      def test_put_path
        path = "https://1.2.3.4/core/v1/fakeresource"
        data = { fake: "data" }
        with_mock_connection(method: :put, path: path, data: data, headers: {}) do
          rest_client = RESTClient.new(config: @config, context: @config.current_context, path: "core/v1")
          rest_client.put("fakeresource", data: data, as: :raw)
        end
      end

      def test_patch_path_json_patch
        path = "https://1.2.3.4/core/v1/fakeresource"
        data = [{ "op" => "add", "path" => "/fake/path", "value" => "test" }]
        headers = { "Content-Type" => "application/json-patch+json" }
        with_mock_connection(method: :patch, path: path, data: data, headers: headers) do
          rest_client = RESTClient.new(config: @config, context: @config.current_context, path: "core/v1")
          rest_client.patch("fakeresource", strategy: :json, data: data, headers: headers, as: :raw)
        end
      end

      def test_delete_path
        with_mock_connection(method: :delete, path: "https://1.2.3.4/core/v1/fakeresource") do
          rest_client = RESTClient.new(config: @config, context: @config.current_context, path: "core/v1")
          rest_client.delete("fakeresource", as: :raw)
        end
      end

      def test_rest_method_returns_error_when_invalid_response_type_set
        with_mock_connection(method: :get, path: "https://1.2.3.4") do
          rest_client = RESTClient.new(config: @config, context: @config.current_context)
          assert_raises(ResponseFormatter::UnsupportedResponseTypeError) { rest_client.get(as: :bogus_type) }
        end
      end

      def test_rest_method_returns_recursive_open_struct_object_by_default
        mock_response = mock_faraday_response
        mock_response.expects(:body).returns(JSON.dump({ fake: "data" }))
        with_mock_connection(method: :get, path: "https://1.2.3.4", returns: mock_response) do
          rest_client = RESTClient.new(config: @config, context: @config.current_context)
          response = rest_client.get
          assert(response.is_a?(RecursiveOpenStruct))
        end
      end

      private

      def with_mock_connection(method:, path: nil, returns: nil, **kwargs)
        mock_connection = mock.responds_like_instance_of(Faraday::Connection)
        mock_connection.expects(method).with(URI.parse(path), *kwargs.values).returns(returns)
        RESTClient.any_instance.stubs(:connection).returns(mock_connection)
        yield
      end

      def mock_faraday_response
        mock.responds_like_instance_of(Faraday::Response)
      end
    end
  end
end
