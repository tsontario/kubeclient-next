# frozen_string_literal: true

require "cluster_integration_test_helper"

module K8y
  class DiscoveryTest < IntegrationTestCase
    def test_discovery_generates_methods_from_verbs
      expected_methods = [
        :create_configmap,
        :delete_configmap,
        :get_configmap,
        :get_configmaps,
        :patch_configmap,
        :update_configmap,
      ]
      assert(expected_methods.none? { |method| client.respond_to?(method) })
      client.discover!
      assert(expected_methods.all? { |method| client.respond_to?(method) })
    end
  end
end
