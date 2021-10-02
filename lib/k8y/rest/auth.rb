# frozen_string_literal: true

require_relative "auth/factory"

module K8y
  module REST
    module Auth
      extend self
      InvalidAuthTypeError = Class.new(Error)

      def from_kubeconfig(kubeconfig, context: nil)
        context = context ? context : kubeconfig.current_context
        auth_info = kubeconfig.user_for_context(context).auth_info
        Factory.new_from_kubeconfig_auth_info(auth_info)
      end
    end
  end
end
