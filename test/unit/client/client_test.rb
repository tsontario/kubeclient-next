# frozen_string_literal: true

require "test_helper"

module KubeclientNext
  module Client
    class ClientTest < TestCase
      def setup
        super
        @client = Client.new(config: config_fixture, context: config_fixture.current_context)
      end

      def test_client_context_uses_first_context_if_not_explicitly_set_in_constructor
        assert_equal(@client.context.name, config_fixture.contexts.first.name)
      end

      def test_method_missing_raises_when_multiple_apis_expose_same_method
        bogus_v1 = API.new(group_version: GroupVersion.new(group: "bogus", version: "v1"))
        bogus_v2 = API.new(group_version: GroupVersion.new(group: "bogus", version: "v2"))
        @client.apis.expects(:apis_for_method).with(:get_boguses).returns([bogus_v1, bogus_v2])
        assert_raises(Client::APINameConflictError) { @client.get_boguses }
      end

      def test_method_missing_raises_no_method_error_when_no_apis_respond_to_method
        @client.apis.expects(:apis_for_method).with(:get_boguses).returns([])
        assert_raises(NoMethodError) { @client.get_boguses }
      end
    end
  end
end
