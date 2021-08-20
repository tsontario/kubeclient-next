# frozen_string_literal: true

require "integration_test_helper"

module KubeclientNext
  class ClientTest < IntegrationTestCase
    KUBE_ROOT_CONFIGMAP = "kube-root-ca.crt"
    def setup
      client.discover!
    end

    def test_get_configmap
      create_from_fixture("config_map")
      configmap = client.get_configmap(namespace: @namespace, name: "test-configmap")
      assert_equal("test-configmap", configmap.metadata.name)
      assert_equal(@namespace, configmap.metadata.namespace)
    end

    def test_get_configmaps
      create_from_fixture("config_map")
      create_from_fixture("config_map_2")
      configmaps = client.get_configmaps(namespace: @namespace)
      configmaps.reject! { |cm| cm.metadata.name == KUBE_ROOT_CONFIGMAP }

      assert_equal(2, configmaps.length)
      test_configmap = configmaps.find { |cm| cm.metadata.name == "test-configmap" }
      test_configmap_2 = configmaps.find { |cm| cm.metadata.name == "test-configmap-2" }
      assert_equal({ foo: "bar" }, test_configmap.data.to_h)
      assert_equal({ baz: "bat" }, test_configmap_2.data.to_h)
    end
  end
end
