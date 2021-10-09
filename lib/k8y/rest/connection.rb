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
          new(host: config.host, ssl: config.transport.to_faraday_options, auth: config.auth)
        end
      end

      def initialize(host:, ssl:, auth:, &conn_options)
        @host = host
        @auth = auth
        @connection = Faraday.new(host, ssl: ssl) do |connection|
          connection.use(Faraday::Response::RaiseError)
          auth.configure_connection(connection)
          yield connection if block_given?
        end
      end

      def generate_token!
        auth.generate_token! if auth.respond_to?(:generate_token!)
        @connection.tap { |connection| auth.configure_connection(connection) }
      end

      private

      attr_reader :auth
    end
  end
end
