# frozen_string_literal: true

require "test_helper"

module KubeclientNext
  module Kubeconfig
    class UserTest < KubeclientNext::TestCase
      def test_from_hash_success
        user_hash = YAML.load_file(kubeconfig_fixture_path("simple")).fetch("users").first
        user = User.from_hash(user_hash)
        assert_equal("test-user", user.name)
        assert_equal("some-username", user.auth_info.username)
        assert_equal("some-password", user.auth_info.password)
      end
    end
  end
end
