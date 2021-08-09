# frozen_string_literal: true

require "test_helper"

module KubeclientNext
  module Kubeconfig
    class ConfigTest < KubeclientNext::TestCase
      def test_from_hash_raises_error_when_missing_keys
        config_hash = YAML.load_file(kubeconfig_fixture_path("simple"))
        ["apiVersion", "kind", "preferences", "clusters", "contexts", "users", "current-context"].each do |key|
          assert_raises(Error) do
            hash = config_hash.dup
            hash.delete(key)
            Config.from_hash(hash)
          end
        end
      end

      def test_cluster_for_context
        assert_equal("test-cluster", config_fixture.cluster_for_context("test").name)
      end

      def test_cluster_for_context_raises_context_not_found_error_when_given_non_existent_context
        assert_raises(Config::ContextNotFoundError) { config_fixture.cluster_for_context("bogus") }
      end

      def test_cluster_for_context_raises_cluster_not_found_error_when_given_non_existent_context
        config = config_fixture("mismatched_cluster_context")
        assert_raises(Config::ClusterNotFoundError) { config.cluster_for_context("test") }
      end

      def test_user_for_context
        assert_equal("test-user", config_fixture.user_for_context("test").name)
      end

      def test_user_for_context_raises_context_not_found_error_when_given_non_existent_context
        assert_raises(Config::ContextNotFoundError) { config_fixture.user_for_context("bogus") }
      end

      def test_user_for_context_raises_user_not_found_error_when_no_matching_user_record_found_for_context
        config = config_fixture("mismatched_user_context")
        assert_raises(Config::UserNotFoundError) { config.user_for_context("test") }
      end
    end
  end
end
