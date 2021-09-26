# frozen_string_literal: true
require_relative "config_validator"
require_relative "transport"
require_relative "auth"

module K8y
  module REST
    class Config
      class << self
        def from_kubeconfig(kubeconfig, context: nil)
          context = context ? context : kubeconfig.current_context
          ConfigValidator.new(kubeconfig, context: context).validate!

          cluster = kubeconfig.cluster_for_context(context)
          host = cluster.server
          transport = if host.scheme == "https"
            Transport.from_kubeconfig(kubeconfig, context: context)
          end
          auth = Auth.from_kubeconfig(kubeconfig, context: context)
          new(
            host: host,
            transport: transport,
            auth: auth
          )
        end
      end

      def initialize(host:, transport:, auth:)
        @host = host
        @transport = transport
        @auth = auth
      end
    end
  end
end
