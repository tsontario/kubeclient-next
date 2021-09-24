# TODO: Move REST client and related to its own module and let K8y::Client build on top of it
module K8y
  module REST
    class Config
      class << self
        def from_kubeconfig(kubeconfig)
          ConfigValidator.new(kubeconfig).validate!

          context = kubeconfig.current_context
          auth_info = kubeconfig.user_for_context(context)
          cluster = kubeconfig.cluster_for_context(context)
          host = cluster.server
          # TODO: proxy-url support
          # TODO: override mechanism (e.g. for timeout, etc. See overrides.go in client-go)
          # TODO: impersonate support
          if host.scheme == "https"
        end

        private

      end
    end
  end
end
