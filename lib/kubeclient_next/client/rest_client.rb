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

      def post(sub_path = "", data:, headers: {})
        headers = { "Content-Type" => "application/json" }.merge(headers)
        connection.post(formatted_uri(host, path, sub_path), data, headers)
      end

      def get(sub_path = "", headers: {})
        connection.get(formatted_uri(host, path, sub_path))
      end

      def put(sub_path = "", data:, headers: {})
        headers = { "Content-Type" => "application/json" }.merge(headers)
        connection.put(formatted_uri(host, path, sub_path), data, headers)
      end

      def patch(sub_path="", stategy:, data:, headers: {})
        headers = { "Content-Type" => content_type_for_patch_strategy(strategy) }.merge(headers)
        connection.patch(formatted_uri(host, path, sub_path), data, headers)
      end

      def delete(sub_path = "", headers: {})
        connection.delete(formatted_uri(host, path, sub_path))
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

      def content_type_for_patch_strategy(strategy)
        case strategy
        when :strategic_merge
          "application/strategic-merge-patch+json"
        when :merge
          "application/merge-patch+json"
        when :json
          "application/json-patch+json"
        end
      end
    end
  end
end
