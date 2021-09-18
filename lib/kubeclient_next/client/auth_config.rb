# frozen_string_literal: true
module KubeclientNext
  module Client
    class AuthConfig
      attr_reader :config
      def new(config:)
        @config = config
      end

      def infer_config!
        if in_cluster_config?
          in_cluster_config
        end
      end

      private

      def in_cluster_config?
        ENV["KUBERNETES_SERVICE_HOST"] &&
          # port = ENV["KUBERNETES_SERVICE_PORT"] &&
          config.auth_info.token_file == Kubeconfig::TOKEN_FILE
      end
    end
  end
end
