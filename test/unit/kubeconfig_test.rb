# frozen_string_literal: true

require "test_helper"

module K8y
  class KubeconfigTest < TestCase
    def test_from_file_fully_loads_simple_kubeconfig_file
      fixture_file = File.open(kubeconfig_fixture_path("simple"))
      config = K8y::Kubeconfig.from_file(fixture_file)
      assert_equal("v1", config.api_version)
      assert_equal("Config", config.kind)
      assert_equal({ "color" => true }, config.preferences)
      assert_equal("test", config.current_context)

      clusters = config.clusters
      assert_equal(1, clusters.length)
      cluster = clusters.first
      assert_equal("test-cluster", cluster.name)
      assert_equal("fake-ca-data", cluster.certificate_authority_data)
      assert_equal("https://1.2.3.4", cluster.server)
      refute(cluster.insecure_skip_tls_verify)

      contexts = config.contexts
      assert_equal(1, contexts.length)
      context = contexts.first
      assert_equal("test", context.name)
      assert_equal("test-cluster", context.cluster)
      assert_equal("test-ns", context.namespace)
      assert_equal("test-user", context.user)
    end
  end
end
