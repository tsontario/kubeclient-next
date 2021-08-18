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

      def test_context_setter_raises_if_non_existent_context_given
        assert_raises(Kubeconfig::Config::ContextNotFoundError) { @client.set_context("bogus") }
      end
    end
  end
end
