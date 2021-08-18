# frozen_string_literal: true

require "integration_test_helper"

module KubeclientNext
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
      assert(expected_methods.none? { |method| client.methods.include?(method) })
      client.discover!
      assert(expected_methods.all? { |method| client.methods.include?(method) })
    end

    # TODO: make a well-known namespace with test resources
    # Note: will probably need to implement the recursive-open-struct return values for RESTClient
    # responses...

    private

    def client(group_versions: [GroupVersion.new(group: "core", version: "v1")])
      @client ||= Client.from_config(kubeconfig, group_versions: group_versions)
    end
  end
end
