
# frozen_string_literal: true

require "test_helper"

module KubeclientNext
  module Kubeconfig
    class ClusterTest < KubeclientNext::TestCase
      def test_from_hash_success
        cluster_hash = YAML.load_file(kubeconfig_fixture_path("simple")).fetch("clusters").first
        cluster = Cluster.from_hash(cluster_hash)
        refute(cluster.insecure_skip_tls_verify)
        assert_equal("test-cluster", cluster.name)
        assert_equal("fake-ca-file", cluster.certificate_authority)
        assert_equal(URI.parse("https://1.2.3.4"), cluster.server)
      end
    end
  end
end
