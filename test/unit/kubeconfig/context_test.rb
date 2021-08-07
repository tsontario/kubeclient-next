# frozen_string_literal: true

require "test_helper"

module KubeclientNext
  module Kubeconfig
    class ContextTest < KubeclientNext::TestCase
      def test_from_hash_success
        context_hash = YAML.load_file(kubeconfig_fixture_path("simple")).fetch("contexts").first
        context = Context.from_hash(context_hash)
        assert_equal("test", context.name)
        assert_equal("test-cluster", context.cluster)
        assert_equal("test-user", context.user)
        assert_equal("test-ns", context.namespace)
      end

      def test_from_hash_raises_error_when_cluster_missing
        context_hash = YAML.load_file(kubeconfig_fixture_path("simple")).fetch("contexts").first
        context_hash["context"].delete("cluster")
        assert_raises(Error) { Context.from_hash(context_hash) }
      end

      def test_from_hash_raises_error_when_user_missing
        context_hash = YAML.load_file(kubeconfig_fixture_path("simple")).fetch("contexts").first
        context_hash["context"].delete("user")
        assert_raises(Error) { Context.from_hash(context_hash) }
      end

      def test_from_hash_raises_error_when_name_missing
        context_hash = YAML.load_file(kubeconfig_fixture_path("simple")).fetch("contexts").first
        context_hash.delete("name")
        assert_raises(Error) { Context.from_hash(context_hash) }
      end

      def test_from_hash_default_namespace_value_is_nil
        context_hash = YAML.load_file(kubeconfig_fixture_path("simple")).fetch("contexts").first
        context_hash["context"].delete("namespace")
        context = Context.from_hash(context_hash)
        assert_nil(context.namespace)
      end
    end
  end
end
