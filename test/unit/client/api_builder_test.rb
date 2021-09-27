# frozen_string_literal: true

require "test_helper"

module K8y
  module Client
    class APIBuilderTest < TestCase
      def setup
        super
      end

      def test_build!
        mock_connection = Faraday.new do |builder|
          builder.adapter(:test, Faraday::Adapter::Test::Stubs.new) do |stub|
            stub.get("https://1.2.3.4/apis/test/v1") { |_env| [200, {}, discovery_response_fixture("test_v1")] }
          end
        end
        connection = REST::Connection.new(host: "https://1.2.3.4/apis/test/v1", auth: REST::Auth.new, ssl: {})
        connection.expects(:connection).returns(mock_connection)

        config = config_fixture("api_builder")
        api = API.new(group_version: GroupVersion.new(group: "test", version: "v1"))
        refute(api.respond_to?(:get_testresource))
        refute(api.respond_to?(:get_testresources))
        refute(api.discovered?)
        builder = APIBuilder.new(api: api, config: config, context: config.current_context)
        builder.build!
        assert(api.discovered?)
        assert(api.respond_to?(:get_testresource))
        assert(api.respond_to?(:get_testresources))
      end
    end
  end
end
