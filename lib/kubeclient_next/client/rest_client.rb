# frozen_string_literal: true
require "faraday"
require "base64"

module KubeclientNext
  module Client
    class RESTClient
      attr_reader :group, :version

      def initialize(config:, context:, group:, version:)
        @config = config
        @context = context
        @group = group
        @version = version

        cert_store = OpenSSL::X509::Store.new
        cert_store.add_cert(OpenSSL::X509::Certificate.new(Base64.decode64(cluster.certificate_authority_data)))
        @connection = Faraday.new(
          endpoint,
          ssl: {
            client_cert: OpenSSL::X509::Certificate.new(Base64.decode64(user.auth_info.client_certificate_data)),
            client_key: OpenSSL::PKey::RSA.new(Base64.decode64(user.auth_info.client_key_data)),
            cert_store: cert_store,
          }
        )
      end

      def get(path = nil)
        @connection.get(path)
      end

      private

      attr_reader :config, :context, :connection

      # Core/v1 resources are in `/api/#{version}`. In general, all other resources are found in `/apis/GROUP/VERSION`
      def endpoint
        @endpoint ||= if group == "core"
          URI.join(host,
            "/api/#{version}")
        else
          URI.join(host, "/apis/#{@group}/#{@version}")
        end
      end

      def host
        cluster.server
      end

      def cluster
        config.cluster_for_context(context)
      end

      def user
        config.user_for_context(context)
      end
    end
  end
end
