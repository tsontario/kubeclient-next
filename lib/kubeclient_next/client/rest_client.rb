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
        @connection = Faraday::Connection.new(endpoint)

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

      def get_events(namespace:)
        @connection.get("events")
      end

      private

      attr_reader :config, :context, :connection

      def endpoint
        @endpoint ||= group ? URI.join(host, @group, @version) : URI.join(host, @version)
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
