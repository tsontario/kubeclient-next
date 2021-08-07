# frozen_string_literal: true

require "test_helper"

module KubeclientNext
  module Kubeconfig
    class ConfigTest < KubeclientNext::TestCase
      def test_from_hash_raises_error_when_missing_keys
        config_hash = YAML.load_file(kubeconfig_fixture_path("simple"))
        ["apiVersion", "kind", "preferences", "clusters", "contexts", "users", "current-context"].each do |key|
          assert_raises(Error) do
            hash = config_hash.dup
            hash.delete(key)
            Config.from_hash(hash)
          end
        end
      end
    end
  end
end
