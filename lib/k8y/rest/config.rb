# frozen_string_literal: true

require_relative "config_validator"
require_relative "transport"
require_relative "auth"

module K8y
  module REST
    class Config
      attr_reader :base_path, :transport, :auth

      class << self
        def from_kubeconfig(kubeconfig, context: nil, path: "/")
          context = context ? context : kubeconfig.current_context
          ConfigValidator.new(kubeconfig, context: context).validate!

          cluster = kubeconfig.cluster_for_context(context)
          base_path = File.join(cluster.server, path)
          transport = if URI(base_path).scheme == "https"
            Transport.from_kubeconfig(kubeconfig, context: context)
          end
          auth = Auth.from_kubeconfig(kubeconfig, context: context)
          new(
            base_path: base_path,
            transport: transport,
            auth: auth
          )
        end
      end

      def initialize(base_path:, transport:, auth:)
        @base_path = base_path
        @transport = transport
        @auth = auth
      end
    end
  end
end
