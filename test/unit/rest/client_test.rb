# frozen_string_literal: true

require "test_helper"

module K8y
  module REST
    class ClientTest < TestCase
      def test_get_root_path
        with_client do |client|
          faraday_expectations(client: client, method: :get, path: client.host)
          client.get(as: :raw)
        end
      end

      def test_get_path
        with_client(host: "https://1.2.3.4/core/v1/") do |client|
          faraday_expectations(client: client, method: :get, path: client.host)
          client.get(as: :raw)
        end
      end

      # def test_get_path_and_subpath
      #   with_mock_connection(method: :get, path: "https://1.2.3.4/core/v1/configmaps") do
      #     client = Client.new(config: @config, context: @config.current_context, path: "core/v1")
      #     client.get("configmaps", as: :raw)
      #   end
      # end

      # def test_get_root_path_and_subpath
      #   with_mock_connection(method: :get, path: "https://1.2.3.4/subpath") do
      #     client = Client.new(config: @config, context: @config.current_context)
      #     client.get("subpath", as: :raw)
      #   end
      # end

      # def test_get_transparently_handles_slashes_in_path_param
      #   with_mock_connection(method: :get, path: "https://1.2.3.4/path/subpath") do
      #     client = Client.new(config: @config, context: @config.current_context, path: "/path/")
      #     client.get("subpath", as: :raw)
      #   end
      # end

      # def test_post_path
      #   path = "https://1.2.3.4/core/v1/fakeresource"
      #   data = { fake: "data" }
      #   headers = { "Content-Type" => "application/json" }
      #   with_mock_connection(method: :post, path: path, data: data, headers: headers) do
      #     client = Client.new(config: @config, context: @config.current_context, path: "core/v1")
      #     client.post("fakeresource", data: data, headers: headers, as: :raw)
      #   end
      # end

      def test_put_path
        path = "fakeresource"
        data = { fake: "data" }
        with_client(host: "https://1.2.3.4/core/v1/") do |client|
          faraday_expectations(client: client, method: :put, path: File.join(client.host, path), data: data,
            headers: {})
          client.put("fakeresource", data: data, as: :raw)
        end
      end

      # def test_patch_path_json_patch
      #   path = "https://1.2.3.4/core/v1/fakeresource"
      #   data = [{ "op" => "add", "path" => "/fake/path", "value" => "test" }]
      #   headers = { "Content-Type" => "application/json-patch+json" }
      #   with_mock_connection(method: :patch, path: path, data: data, headers: headers) do
      #     client = Client.new(config: @config, context: @config.current_context, path: "core/v1")
      #     client.patch("fakeresource", strategy: :json, data: data, headers: headers, as: :raw)
      #   end
      # end

      # def test_delete_path
      #   with_mock_connection(method: :delete, path: "https://1.2.3.4/core/v1/fakeresource") do
      #     client = Client.new(config: @config, context: @config.current_context, path: "core/v1")
      #     client.delete("fakeresource", as: :raw)
      #   end
      # end

      # def test_rest_method_returns_error_when_invalid_response_type_set
      #   with_mock_connection(method: :get, path: "https://1.2.3.4") do
      #     client = Client.new(config: @config, context: @config.current_context)
      #     assert_raises(ResponseFormatter::UnsupportedResponseTypeError) { client.get(as: :bogus_type) }
      #   end
      # end

      # def test_rest_method_returns_recursive_open_struct_object_by_default
      #   mock_response = mock_faraday_response
      #   mock_response.expects(:body).returns(JSON.dump({ fake: "data" }))
      #   with_mock_connection(method: :get, path: "https://1.2.3.4", returns: mock_response) do
      #     client = Client.new(config: @config, context: @config.current_context)
      #     response = client.get
      #     assert(response.is_a?(RecursiveOpenStruct))
      #   end
      # end

      private

      def with_client(host: "https://1.2.3.4/", auth: Auth.new, ssl: {})
        connection = Connection.new(host: host, auth: Auth.new, ssl: {})
        yield(Client.new(connection: connection))
      end

      def faraday_expectations(client:, method:, path:, returns: nil, **kwargs)
        target = client.connection.connection
        target.expects(method).with(path, *kwargs.values).returns(returns)
      end

      def mock_faraday_response
        mock.responds_like_instance_of(Faraday::Response)
      end
    end
  end
end
