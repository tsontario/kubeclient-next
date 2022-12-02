# frozen_string_literal: true

require_relative "auth/factory"
# Another crazy comment! Woah!
module K8y
  module REST
    module Auth
      class << self
        def from_kubeconfig(kubeconfig, context: nil)
          context = context ? context : kubeconfig.current_context
          auth_info = kubeconfig.user_for_context(context).auth_info
          from_auth_info(auth_info)
        end

        def from_auth_info(auth_info)
          Factory.new.from_auth_info(auth_info)
        end
      end
    end
  end
end
