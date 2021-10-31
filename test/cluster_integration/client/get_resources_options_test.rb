# frozen_string_literal: true

require "cluster_integration_test_helper"

module K8y
  module Client
    class APITest < IntegrationTestCase
      def setup
        client.discover!
      end

      def test_label_selector_selects_pods_with_matching_label
        create_from_fixture("deployment")
        create_from_fixture("deployment_extra_labels")

        deployments = client.get_deployments(namespace: @namespace)
        assert_equal(2, deployments.length)

        label_selected = client.get_deployments(namespace: @namespace, label_selector: "extra=labels")
        assert_equal(1, label_selected.length)
        assert_equal("busybox-extra-labels", label_selected.first.metadata.name)
      end
    end
  end
end
