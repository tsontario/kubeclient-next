# frozen_string_literal: true

require "test_helper"

module K8y
  module Client
    class ResourceDescriptionTest < TestCase
      def test_from_hash
        hash = YAML.load_file(resource_description_fixture_path("configmaps"))
        name = hash["name"]
        singular_name = hash["singularName"]
        namespaced = hash["namespaced"]
        kind = hash["kind"]
        verbs = hash["verbs"]
        assert_equal("configmaps", name)
        assert_equal("", singular_name)
        assert(namespaced)
        assert_equal("ConfigMap", kind)
        assert_equal(["create", "delete", "deletecollection", "get", "list", "patch", "update", "watch"], verbs)

        resource_description = ResourceDescription.from_hash(hash)
        assert_equal(name, resource_description.name)
        assert_equal("configmap", resource_description.singular_name)
        assert(resource_description.namespaced)
        assert_equal(kind, resource_description.kind)
        assert_equal(verbs.map(&:to_sym), resource_description.verbs)
      end

      def test_singular_name_uses_singular_name_field_when_present
        hash = YAML.load_file(resource_description_fixture_path("configmaps"))
        hash["singularName"] = "singular_name"
        resource_description = ResourceDescription.from_hash(hash)
        assert_equal("singular_name", resource_description.singular_name)
      end

      def test_singular_name_falls_back_to_downcased_kind_when_not_present
        hash = YAML.load_file(resource_description_fixture_path("configmaps"))
        hash["singularName"] = ""
        resource_description = ResourceDescription.from_hash(hash)
        assert_equal(hash["kind"].downcase, resource_description.singular_name)
      end

      def test_subresource?
        not_a_subresource = ResourceDescription.from_hash(resource_description_fixture("configmaps"))
        subresource = ResourceDescription.from_hash(resource_description_fixture("serviceaccounts-token"))
        refute(not_a_subresource.subresource?)
        assert(subresource.subresource?)
      end

      def test_has_verb?
        hash = YAML.load_file(resource_description_fixture_path("serviceaccounts-token"))
        assert_equal(["create"], hash.fetch("verbs"))
        resource = ResourceDescription.from_hash(hash)
        assert(resource.has_verb?(:create))
        refute(resource.has_verb?(:bogus))
      end

      def test_path_for_resources
        resource_description = ResourceDescription.from_hash(resource_description_fixture("configmaps"))
        namespaced_path = resource_description.path_for_resources(namespace: "test-ns")
        non_namepsaced_path = resource_description.path_for_resources

        assert_equal("namespaces/test-ns/configmaps", namespaced_path)
        assert_equal("configmaps", non_namepsaced_path)
      end

      def test_path_for_resource
        resource_description = ResourceDescription.from_hash(resource_description_fixture("configmaps"))
        namespaced_path = resource_description.path_for_resource(namespace: "test-ns", name: "test")
        non_namepsaced_path = resource_description.path_for_resource(name: "test")

        assert_equal("namespaces/test-ns/configmaps/test", namespaced_path)
        assert_equal("configmaps/test", non_namepsaced_path)
      end

      private

      def resource_description_fixture(name)
        YAML.load_file(resource_description_fixture_path(name))
      end

      def resource_description_fixture_path(name)
        File.expand_path(File.join("..", "..", "fixtures", "resource_description", "#{name}.yml"), __dir__)
      end
    end
  end
end
