# frozen_string_literal: true

require "test_helper"

module K8y
  class IntegrationTestCase < TestCase
    def integration_fixture(path)
      fixtures_base = File.expand_path(File.join("fixtures", "integration"), __dir__)
      file = File.open(File.join(fixtures_base, "#{path}.yml"))
      Kubeconfig.from_file(file)
    end
  end
end
