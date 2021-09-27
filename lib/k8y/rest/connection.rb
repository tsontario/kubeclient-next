# frozen_string_literal: true

require "forwardable"

module K8y
  module REST
    class Connection
      extend Forwardable

      attr_reader :host, :connection

      VERBS = [:get, :post, :put, :patch, :delete]
      def_delegators(:connection, *VERBS)

      class << self
        # Initialize a Connection object using a provided REST::Config instance
        def from_config(config)
          cert_store = OpenSSL::X509::Store.new
          cert_store.add_cert(OpenSSL::X509::Certificate.new(Base64.decode64(config.transport.ca_data)))
          ssl = {
            client_cert: OpenSSL::X509::Certificate.new(Base64.decode64(config.transport.cert_data)),
            client_key: OpenSSL::PKey::RSA.new(Base64.decode64(config.transport.key_data)),
            cert_store: cert_store,
            verify_ssl: OpenSSL::SSL::VERIFY_PEER,
          }

          new(config.host, ssl: ssl, auth: config.auth)
        end
      end

      def initialize(host:, ssl:, auth:)
        @host = host
        @connection = Faraday.new(host, ssl: ssl) do |connection|
          auth.configure_connection(connection)
        end
      end
    end
  end
end
