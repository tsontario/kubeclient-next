# frozen_string_literal: true

require "test_helper"

module K8y
  module REST
    class AuthTest < TestCase
      def test_from_kubeconfig_creates_basic_auth_when_username_and_password_present
        kubeconfig = config_fixture("simple")
        assert_instance_of(Auth::Basic, Auth.from_kubeconfig(kubeconfig))
      end

      def test_from_auth_info_creates_token_auth_when_username_and_password_present
        kubeconfig = config_fixture("auth_token")
        assert_instance_of(Auth::Token, Auth.from_kubeconfig(kubeconfig))
      end

      def test_from_kubeconfig_calls_auth_provider_factory_if_auth_provider_present
        Auth::Providers::Factory.any_instance.expects(:from_auth_provider)
        Auth.from_kubeconfig(config_fixture("auth_provider"))
      end

      def test_from_auth_info_creates_basic_auth_when_username_and_password_present
        auth_info = auth_info_fixture("basic")
        assert_instance_of(Auth::Basic, Auth.from_auth_info(auth_info))
      end

      def test_from_auth_info_creates_token_auth_when_token_present
        auth_info = auth_info_fixture("bearer")
        assert_instance_of(Auth::Token, Auth.from_auth_info(auth_info))
      end

      def test_from_auth_info_calls_auth_provider_factory_if_auth_provider_present
        auth_info = auth_info_fixture("auth_provider_empty")
        Auth::Providers::Factory.any_instance.expects(:from_auth_provider)
        Auth.from_auth_info(auth_info)
      end
    end
  end
end
