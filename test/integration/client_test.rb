# frozen_string_literal: true

require "integration_test_helper"

module KubeclientNext
  class ClientTest < IntegrationTestCase
    KUBE_ROOT_CONFIGMAP = "kube-root-ca.crt"
    def setup
      client.discover!
    end

    def test_get_configmap
      create_from_fixture("configmap")
      configmap = client.get_configmap(namespace: @namespace, name: "test-configmap")
      assert_equal("test-configmap", configmap.metadata.name)
      assert_equal(@namespace, configmap.metadata.namespace)
    end

    def test_get_configmaps
      create_from_fixture("configmap")
      create_from_fixture("configmap_2")
      configmaps = client.get_configmaps(namespace: @namespace)
      configmaps.reject! { |cm| cm.metadata.name == KUBE_ROOT_CONFIGMAP }

      assert_equal(2, configmaps.length)
      test_configmap = configmaps.find { |cm| cm.metadata.name == "test-configmap" }
      test_configmap_2 = configmaps.find { |cm| cm.metadata.name == "test-configmap-2" }
      assert_equal({ foo: "bar" }, test_configmap.data.to_h)
      assert_equal({ baz: "bat" }, test_configmap_2.data.to_h)
    end

    def test_create_configmap
      configmap = YAML.load_file(resource_fixture_path("configmap"))
      create_result = client.create_configmap(name: "test-configmap", namespace: @namespace, data: configmap)
      get_result = client.get_configmap(name: "test-configmap", namespace: @namespace)
      assert_equal(get_result, create_result)
    end

    def test_delete_configmap
      create_from_fixture("configmap")
      delete_result = client.delete_configmap(name: "test-configmap", namespace: @namespace)
      assert_equal("Success", delete_result.status)
      get_result = client.get_configmap(name: "test-configmap", namespace: @namespace)
      assert_equal("NotFound", get_result.reason)
    end

    def test_update_configmap
      create_from_fixture("configmap")
      configmap = client.get_configmap(name: "test-configmap", namespace: @namespace)
      refute(configmap.metadata.annotations)
      configmap.metadata.annotations = { test: "bogus" }
      client.update_configmap(name: "test-configmap", namespace: @namespace, data: configmap.to_h)
      updated = client.get_configmap(name: "test-configmap", namespace: @namespace)
      assert_equal("bogus", updated.metadata.annotations.test)
    end

    def test_json_patch_configmap
      create_from_fixture("configmap")
      configmap = client.get_configmap(name: "test-configmap", namespace: @namespace)
      refute(configmap.data.json_patch)
      patch_data = [{ "op" => "add", "path" => "/data/json_patch", "value" => "test" }]
      client.patch_configmap(strategy: :json, name: "test-configmap",
        namespace: @namespace, data: patch_data)
      patched = client.get_configmap(name: "test-configmap", namespace: @namespace)
      assert_equal("test", patched.data.json_patch)
    end

    def test_merge_patch_configmap
      create_from_fixture("configmap")
      configmap = client.get_configmap(name: "test-configmap", namespace: @namespace)
      refute(configmap.data.merge_patch)
      patch_data = { data: { merge_patch: "test" } }
      client.patch_configmap(strategy: :merge, name: "test-configmap",
        namespace: @namespace, data: patch_data)
      patched = client.get_configmap(name: "test-configmap", namespace: @namespace)
      assert_equal("test", patched.data.merge_patch)
    end

    def test_strategic_merge_patch_configmap
      # TODO: need to actually test something with a list to ensure strategic directives are
      # actually being followed by the patch (e.g. Pod w/ busybox containers)
    end

    def test_client_raises_argument_error_when_unsupported_patch_strategy_specified
      assert_raises(ArgumentError) do
        client.patch_configmap(name: "foo", namespace: @namespace, data: { data: { fake: "data" } }, strategy: :fake)
      end
    end
  end
end
