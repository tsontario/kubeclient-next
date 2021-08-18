# frozen_string_literal: true
require "simplecov"
SimpleCov.start

require "kubeclient_next"

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

module KubeclientNext
  class TestCase < ::Minitest::Test
    def run
      disable_net_connect? ? WebMock.disable_net_connect! : WebMock.enable_net_connect!
      yield if block_given?
      super
    end

    def config_fixture(fixture = "simple")
      fixture_file = File.open(kubeconfig_fixture_path(fixture))
      KubeclientNext::Kubeconfig.from_file(fixture_file)
    end

    def kubeconfig_fixture_path(name, sub_dir: "")
      File.expand_path(File.join("fixtures", "kubeconfig", sub_dir, "#{name}.yml"), __dir__)
    end

    private

    def disable_net_connect?
      true
    end
  end
end
