# frozen_string_literal: true

require "test_helper"
require "open3"

module KubeclientNext
  class IntegrationTestCase < TestCase
    KubeconfigError = Class.new(RuntimeError)
    def kubeconfig
      config_file = if ENV["KUBECLIENT_TEST_CONFIG"]
        File.open(ENV["KUBECLIENT_TEST_CONFIG"])
      else
        kind_kubeconfig
      end
      Kubeconfig.from_file(config_file)
    end

    private

    def disable_net_connect?
      false
    end

    def kind_kubeconfig
      out, err, st = Open3.capture3("kind get kubeconfig")
      raise KubeconfigError, "Failed to get kubeconfig from kind: #{err}" unless st.success?
      StringIO.new(out)
    end
  end
end
