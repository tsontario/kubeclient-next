# frozen_string_literal: true

require "test_helper"

module K8y
  module REST
    class ClientTest < TestCase
      def test_from_config
        auth = Auth::Token.new(token: "fake-token")
        transport = Transport.new
        config = Config.new(
          base_path: "base_path",
          transport: transport,
          auth: auth
        )

        client = Client.from_config(config)
        auth_header = "Bearer fake-token"
        assert_equal("base_path", client.base_path)
        assert_equal(auth_header, client.connection.connection.headers[:Authorization])
      end

      def test_get_root_path
        with_client do |client|
          faraday_expectations(client: client, method: :get, path: client.base_path)
          client.get(as: :raw)
        end
      end

      def test_get_path
        with_client(base_path: "https://1.2.3.4/core/v1/") do |client|
          faraday_expectations(client: client, method: :get, path: client.base_path)
          client.get(as: :raw)
        end
      end

      def test_get_path_and_subpath
        path = "configmaps"
        with_client(base_path: "https://1.2.3.4/core/v1/") do |client|
          faraday_expectations(client: client, method: :get, path: File.join(client.base_path, path))
          client.get(path, as: :raw)
        end
      end

      def test_get_root_path_and_subpath
        path = "subpath"
        with_client(base_path: "https://1.2.3.4/") do |client|
          faraday_expectations(client: client, method: :get, path: File.join(client.base_path, path))
          client.get(path, as: :raw)
        end
      end

      def test_get_transparently_handles_slashes_in_path_param
        path = "/sub/path/"
        with_client(base_path: "https://1.2.3.4/") do |client|
          faraday_expectations(client: client, method: :get, path: "https://1.2.3.4/sub/path/")
          client.get(path, as: :raw)
        end
      end

      def test_post_path
        base_path = "https://1.2.3.4/core/v1/"
        path = "fakeresource"
        body = { fake: "data" }
        headers = { "Content-Type" => "application/json" }
        with_client(base_path: base_path) do |client|
          faraday_expectations(client: client, method: :post, path: File.join(base_path, path),
            body: body, headers: headers)
          client.post("fakeresource", body: body, headers: headers, as: :raw)
        end
      end

      def test_put_path
        path = "fakeresource"
        body = { fake: "data" }
        with_client(base_path: "https://1.2.3.4/core/v1/") do |client|
          faraday_expectations(client: client, method: :put, path: File.join(client.base_path, path), body: body,
            headers: {})
          client.put("fakeresource", body: body, as: :raw)
        end
      end

      def test_patch_path_json_patch
        base_path = "https://1.2.3.4/core/v1/"
        path = "fakeresource"
        body = [{ "op" => "add", "path" => "/fake/path", "value" => "test" }]
        headers = { "Content-Type" => "application/json-patch+json" }
        with_client(base_path: base_path) do |client|
          faraday_expectations(client: client, method: :patch, path: File.join(base_path, path),
            body: body, headers: headers)
          client.patch("fakeresource", strategy: :json, body: body, headers: headers, as: :raw)
        end
      end

      def test_delete_path
        base_path = "https://1.2.3.4/core/v1/"
        path = "fakeresource"
        with_client(base_path: base_path) do |client|
          faraday_expectations(client: client, method: :delete, path: File.join(base_path, path))
          client.delete("fakeresource", as: :raw)
        end
      end

      def test_rest_method_returns_error_when_invalid_response_type_set
        base_path = "https://1.2.3.4/"
        with_client(base_path: base_path) do |client|
          faraday_expectations(client: client, method: :get, path: base_path)
          assert_raises(ResponseFormatter::UnsupportedResponseTypeError) { client.get(as: :bogus_type) }
        end
      end

      def test_rest_method_returns_k8y_resource_object_by_default
        base_path = "https://1.2.3.4/"
        mock_response = mock_faraday_response
        mock_response.expects(:body).returns(JSON.dump({ fake: "data" }))
        with_client(base_path: base_path) do |client|
          faraday_expectations(client: client, method: :get, path: base_path, returns: mock_response)
          response = client.get
          assert(response.is_a?(Resource))
        end
      end

      private

      def with_client(base_path: "https://1.2.3.4/", auth: Auth::AuthBase.new, ssl: {})
        connection = Connection.new(base_path: base_path, auth: auth, ssl: {})
        yield(Client.new(connection: connection))
      end

      def faraday_expectations(client:, method:, path:, body: {}, params: {}, headers: {}, returns: nil)
        target = client.connection.connection
        case method
        when :patch, :post, :put
          target.expects(method).with(path, body, headers).returns(returns)
        else
          target.expects(method).with(path, params, headers).returns(returns)
        end
      end

      def mock_faraday_response
        mock.responds_like_instance_of(Faraday::Response)
      end
    end
  end
end
