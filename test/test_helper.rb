# frozen_string_literal: true
require "simplecov"
SimpleCov.start

require "k8y"

require "byebug"
require "minitest/autorun"
require "minitest/reporters"
require "mocha/minitest"
require "webmock/minitest"

Mocha.configure do |c|
  c.stubbing_method_unnecessarily = :prevent
  c.stubbing_non_existent_method = :prevent
end

Minitest::Reporters.use!([
  Minitest::Reporters::DefaultReporter.new(
    slow_count: 10,
    detailed_skip: false,
    verbose: ENV["VERBOSE"] == "1"
  ),
])

module K8y
  class TestCase < ::Minitest::Test
    def run
      disable_net_connect? ? WebMock.disable_net_connect! : WebMock.enable_net_connect!
      yield if block_given?
      super
    end

    def config_fixture(fixture = "simple")
      fixture_file = File.open(kubeconfig_fixture_path(fixture))
      K8y::Kubeconfig.from_file(fixture_file)
    end

    def auth_info_fixture(name)
      auth_info_hash = YAML.load_file(kubeconfig_fixture_path(name, sub_dir: "auth_info"))
      K8y::Kubeconfig::AuthInfo.from_hash(auth_info_hash)
    end

    def kubeconfig_fixture_path(name, sub_dir: "")
      File.expand_path(File.join("fixtures", "kubeconfig", sub_dir, "#{name}.yml"), __dir__)
    end

    # Use raw JSON strings as that's what we expect to receive in production
    def discovery_response_fixture(name)
      File.read(discovery_response_fixture_path(name))
    end

    def discovery_response_fixture_path(name)
      File.expand_path(File.join("fixtures", "discovery", "#{name}.json"), __dir__)
    end

    def resource_fixture(name)
      File.read(resource_fixture_path(name))
    end

    def resource_fixture_path(name)
      File.expand_path(File.join("fixtures", "integration", "resources", "#{name}.yml"), __dir__)
    end

    def stub_in_cluster_config
      ENV.expects(:fetch).with("KUBERNETES_SERVICE_HOST", nil).returns("host")
      ENV.expects(:fetch).with("KUBERNETES_SERVICE_PORT", nil).returns("port")

      File.expects(:read).with(Kubeconfig::ROOT_CA_FILE).returns("bogus-ca-data")
      File.expects(:read).with(Kubeconfig::TOKEN_FILE).returns("bogus-token")
    end

    private

    def disable_net_connect?
      true
    end
  end
end
