# frozen_string_literal: true

require "test_helper"

module K8y
  module Kubeconfig
    class AuthInfoTest < TestCase
      def test_from_hash_success
        auth_info_hash = YAML.load_file(kubeconfig_fixture_path("complete", sub_dir: "auth_info"))
        auth_info = AuthInfo.from_hash(auth_info_hash)
        assert_equal("test-client-certificate", auth_info.client_certificate)
        assert_equal("test-client-certificate-data", auth_info.client_certificate_data)
        assert_equal("test-client-key", auth_info.client_key)
        assert_equal("test-client-key-data", auth_info.client_key_data)
        assert_equal("test-token", auth_info.token)
        assert_equal("test-token-file", auth_info.token_file)
        assert_equal("test-as", auth_info.as)
        assert_equal(["test-group"], auth_info.as_groups)
        assert_equal({ "test-key" => "test-value" }, auth_info.as_user_extra)
        assert_equal("test-username", auth_info.username)
        assert_equal("test-password", auth_info.password)
        assert_equal("test-auth-provider", auth_info.auth_provider)
        assert_equal("test-exec", auth_info.exec_options)
        assert_equal("test-extensions", auth_info.extensions)
      end
    end
  end
end
