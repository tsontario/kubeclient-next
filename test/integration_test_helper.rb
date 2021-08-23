# frozen_string_literal: true

require "open3"
require "securerandom"
require "test_helper"

module KubeclientNext
  class IntegrationTestCase < TestCase
    Error = Class.new(RuntimeError)
    KubeconfigError = Class.new(Error)
    MissingContextError = Class.new(Error)
    KubectlError = Class.new(Error)

    if ENV["PARALLELIZE_ME"]
      puts "Running tests in parallel! (# Threads: #{ENV["MT_CPU"]}"
      parallelize_me!
    end

    def run
      super do
        @config = kubeconfig
        @context = ENV["KUBECLIENT_TEST_CONTEXT"] || "kind-kind"
        @namespace = build_test_namespace(name)
      end
    ensure
      delete_namespace(@namespace)
    end

    def kubeconfig
      config_file = if ENV["KUBECLIENT_TEST_CONFIG"]
        unless ENV["KUBECLIENT_TEST_CONTEXT"]
          raise MissingContextError, "KUBECLIENT_TEST_CONTEXT must be set if KUBECLIENT_TEST_CONFIG is set."
        end
        File.open(ENV["KUBECLIENT_TEST_CONFIG"])
      else
        kind_kubeconfig
      end
      Kubeconfig.from_file(config_file)
    end

    def build_test_namespace(test_name)
      prefix = "kubeclient-next"
      suffix = "-#{SecureRandom.hex(8)}"
      max_base_length = 63 - (prefix + suffix).length # namespace name length must be <= 63 chars
      ns_name = prefix + test_name.gsub(/[^-a-z0-9]/, "-").slice(0, max_base_length) + suffix

      create_namespace(ns_name)
      ns_name
    end

    def build_client(group_versions: Client::DEFAULT_GROUP_VERSIONS)
      Client.from_config(kubeconfig, group_versions: group_versions)
    end

    def client
      @client ||= build_client
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

    def create_namespace(name)
      _, err, st = Open3.capture3("kubectl --context=#{@context} create namespace #{name}")
      raise KubectlError, err unless st.success?
      name
    end

    def delete_namespace(name)
      _, err, st = Open3.capture3("kubectl --context=#{@context} delete namespace #{name}")
      raise KubectlError, err unless st.success?
      name
    end

    def create_from_fixture(fixture_name, sub_path: "")
      path = File.expand_path(File.join("fixtures", "integration", "resources", sub_path, "#{fixture_name}.yml"),
        __dir__)
      _, err, st = Open3.capture3("kubectl --context=#{@context} --namespace=#{@namespace} create -f #{path}")
      raise KubectlError, err unless st.success?
      true
    end
  end
end
