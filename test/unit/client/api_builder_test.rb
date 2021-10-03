# frozen_string_literal: true

require "test_helper"

module K8y
  module Client
    class APIBuilderTest < TestCase
      def test_build!
        REST::Connection.expects(:from_config).returns(
          REST::Connection.new(host: "https://1.2.3.4/apis/test/v1/", auth: REST::Auth::AuthBase.new,
            ssl: {}) do |builder|
            builder.adapter(:test, Faraday::Adapter::Test::Stubs.new) do |stub|
              stub.get("https://1.2.3.4/apis/test/v1/") { |_env| [200, {}, discovery_response_fixture("test_v1")] }
            end
          end
        ).at_least(1)

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
