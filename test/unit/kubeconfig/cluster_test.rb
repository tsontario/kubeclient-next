
# frozen_string_literal: true

require "test_helper"

module K8y
  module Kubeconfig
    class ClusterTest < TestCase
      def test_from_hash_success
        cluster_hash = YAML.load_file(kubeconfig_fixture_path("simple")).fetch("clusters").first
        cluster = Cluster.from_hash(cluster_hash)
        refute(cluster.insecure_skip_tls_verify)
        assert_equal("test-cluster", cluster.name)
        assert_equal("fake-ca-data", cluster.certificate_authority_data)
        assert_equal(URI.parse("https://1.2.3.4"), cluster.server)
      end

      def test_from_hash_raises_error_when_missing_server
        cluster_hash = YAML.load_file(kubeconfig_fixture_path("simple")).fetch("clusters").first
        cluster_hash["cluster"].delete("server")
        assert_raises(Error) { Cluster.from_hash(cluster_hash) }
      end

      def test_from_hash_raises_error_when_missing_name
        cluster_hash = YAML.load_file(kubeconfig_fixture_path("simple")).fetch("clusters").first
        cluster_hash.delete("name")
        assert_raises(Error) { Cluster.from_hash(cluster_hash) }
      end

      def test_from_hash_default_value_false_for_insecure_skip_tls_verify
        cluster_hash = YAML.load_file(kubeconfig_fixture_path("simple")).fetch("clusters").first
        cluster_hash["cluster"].delete("insecure-skip-tls-verify")
        cluster = Cluster.from_hash(cluster_hash)
        refute(cluster.insecure_skip_tls_verify)
      end

      def test_from_hash_default_value_nil_for_certificate_authority
        cluster_hash = YAML.load_file(kubeconfig_fixture_path("simple")).fetch("clusters").first
        cluster_hash["cluster"].delete("certificate-authority")
        cluster = Cluster.from_hash(cluster_hash)
        assert_nil(cluster.certificate_authority)
      end
    end
  end
end
