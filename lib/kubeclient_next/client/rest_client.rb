# frozen_string_literal: true

require "faraday"
require "base64"
require "recursive_open_struct"

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

      def get(sub_path = "", headers: {}, as: :ros)
        byebug
        response = connection.get(formatted_uri(host, path, sub_path))
        format_response(response, as)
      end

      def post(sub_path = "", data:, headers: {}, as: :ros)
        response = connection.post(formatted_uri(host, path, sub_path), data, headers)
        format_response(response, as)
      end

      def put(sub_path = "", data:, headers: {}, as: :ros)
        response = connection.put(formatted_uri(host, path, sub_path), data, headers)
        format_response(response, as)
      end

      def patch(sub_path = "", strategy:, data:, headers: {}, as: :ros)
        response = connection.patch(formatted_uri(host, path, sub_path), data, headers)
        format_response(response, as)
      end

      def delete(sub_path = "", headers: {}, as: :ros)
        response = connection.delete(formatted_uri(host, path, sub_path))
        format_response(response, as)
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

      def format_response(response, as:)
        case as
        when :ros
          RecursiveOpenStruct.new(response.body)
        else
          response.body
        end
      end
    end
  end
end
