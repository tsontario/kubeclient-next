# frozen_string_literal: true

require "integration_test_helper"

module K8y
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
      result = client.update_configmap(name: "test-configmap", namespace: @namespace, data: configmap.to_h)
      assert_equal("bogus", result.metadata.annotations.test)
    end

    def test_json_patch_configmap
      create_from_fixture("configmap")
      configmap = client.get_configmap(name: "test-configmap", namespace: @namespace)
      refute(configmap.data.json_patch)
      patch_data = [{ "op" => "add", "path" => "/data/json_patch", "value" => "test" }]
      result = client.patch_configmap(strategy: :json, name: "test-configmap",
        namespace: @namespace, data: patch_data)
      assert_equal("test", result.data.json_patch)
    end

    def test_merge_patch_configmap
      create_from_fixture("configmap")
      configmap = client.get_configmap(name: "test-configmap", namespace: @namespace)
      refute(configmap.data.merge_patch)
      patch_data = { data: { merge_patch: "test" } }
      result = client.patch_configmap(strategy: :merge, name: "test-configmap",
        namespace: @namespace, data: patch_data)
      assert_equal("test", result.data.merge_patch)
    end

    def test_strategic_merge_patch_deployment_default_strategy
      create_from_fixture("deployment")

      deployment = client.get_deployment(name: "busybox", namespace: @namespace)
      assert_equal(1, deployment.spec.template.spec.containers.length)
      refute(deployment.spec.template.spec.containers.map(&:name).include?("addition"))
      patch_data = {
        spec: {
          template: {
            spec: {
              containers: [{
                name: "addition",
                image: "busybox",
                command: ["tail", "-f", "/dev/null"],
              }],
            },
          },
        },
      }
      result = client.patch_deployment(name: "busybox", namespace: @namespace,
        data: patch_data, strategy: :strategic_merge)
      assert_equal(2, result.spec.template.spec.containers.length)
      assert(result.spec.template.spec.containers.map(&:name).include?("addition"))
    end

    def test_strategic_merge_patch_deployment_replace_strategy
      create_from_fixture("deployment")

      deployment = client.get_deployment(name: "busybox", namespace: @namespace)
      assert_equal(1, deployment.spec.template.spec.containers.length)
      refute(deployment.spec.template.spec.containers.map(&:name).include?("replacement"))
      patch_data = {
        spec: {
          template: {
            spec: {
              "$patch": "replace",
              containers: [{
                name: "replacement",
                image: "busybox",
                command: ["tail", "-f", "/dev/null"],
              }],
            },
          },
        },
      }
      result = client.patch_deployment(name: "busybox", namespace: @namespace,
        data: patch_data, strategy: :strategic_merge)
      assert_equal(1, result.spec.template.spec.containers.length)
      assert_equal("replacement", result.spec.template.spec.containers.first.name)
    end

    def test_strategic_metge_patch_deployment_delete_strategy
      create_from_fixture("deployment")

      deployment = client.get_deployment(name: "busybox", namespace: @namespace)
      assert_equal(1, deployment.spec.template.spec.containers.length)
      assert(deployment.spec.template.spec.containers.first.ports)
      patch_data = {
        spec: {
          template: {
            spec: {
              containers: [{
                name: "busybox",
                ports: [
                  "$patch": "delete",
                  containerPort: 8080,
                ],
              }],
            },
          },
        },
      }
      result = client.patch_deployment(name: "busybox", namespace: @namespace,
        data: patch_data, strategy: :strategic_merge)
      refute(result.spec.template.spec.containers.first.ports)
    end

    def test_client_raises_argument_error_when_unsupported_patch_strategy_specified
      assert_raises(ArgumentError) do
        client.patch_configmap(name: "foo", namespace: @namespace, data: { data: { fake: "data" } }, strategy: :fake)
      end
    end
  end
end
