# frozen_string_literal: true

require "test_helper"

module K8y
  module Kubeconfig
    class AuthProviderTest < TestCase
      def test_present_is_false_for_empty_auth_provider
        provider = AuthProvider.new
        refute(provider.present?)
      end

      def test_present_is_true_for_non_empty_auth_provider
        provider = AuthProvider.new(name: "bogus")
        assert(provider.present?)
      end
    end
  end
end
