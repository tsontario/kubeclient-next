# frozen_string_literal: true

require "integration_test_helper"

module KubeclientNext
  class ClientTest < IntegrationTestCase
    def setup
      client.discover!
    end

    def test_get_configmap
      create_from_fixture("config_map")
      configmap = client.get_configmap(namespace: @namespace, name: "test-configmap")
    end

    def test_get_configmaps
      create_from_fixture("config_map")
      create_from_fixture("config_map_2")
      configmaps = client.get_configmaps(namespace: @namespace)
    end
  end
end
