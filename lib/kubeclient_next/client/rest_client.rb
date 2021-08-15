# frozen_string_literal: true

require "faraday"
require "base64"

module KubeclientNext
  module Client
    class RESTClient
      attr_reader :context, :path

      def initialize(config:, context:, path: "")
        @config = config
        @context = context
        @path = path

        # TODO: generically handle auth depending on provided config
        hardcoded_auth
      end

      def get(sub_path = "")
        connection.get(formatted_uri(host, path, sub_path))
      end

      private

      attr_reader :config, :connection

      def hardcoded_auth
        cert_store = OpenSSL::X509::Store.new
        cert_store.add_cert(OpenSSL::X509::Certificate.new(Base64.decode64(cluster.certificate_authority_data)))
        @connection = Faraday.new(
          host,
          ssl: {
            client_cert: OpenSSL::X509::Certificate.new(Base64.decode64(user.auth_info.client_certificate_data)),
            client_key: OpenSSL::PKey::RSA.new(Base64.decode64(user.auth_info.client_key_data)),
            cert_store: cert_store,
          }
        )
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

      def formatted_uri(host, path, sub_path = "")
        if !sub_path.empty? && !path.end_with?("/")
          URI.join(host, "#{path}/", sub_path)
        else
          URI.join(host, path, sub_path)
        end
      end
    end
  end
end
