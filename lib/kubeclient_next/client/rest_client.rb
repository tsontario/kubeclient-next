# frozen_string_literal: true
require "faraday"
require "base64"

module KubeclientNext
  module Client
    class RESTClient
      attr_reader :context, :path

      def initialize(config:, context:, path:)
        @config = config
        @context = context
        @path = path

        # TODO: generically handle auth depending on provided config
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

      # TODO: this is worthy of a comment... dealing with weird URI.join behaviour
      def get(sub_path = "")
        if !sub_path.empty? && !path.end_with?("/")
          @connection.get(URI.join(host, "#{path}/", sub_path))
        else
          @connection.get(URI.join(host, path, sub_path))
        end
      end

      private

      attr_reader :config, :connection

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
