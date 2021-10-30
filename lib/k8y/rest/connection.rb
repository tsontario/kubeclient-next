# frozen_string_literal: true

require "forwardable"

require_relative "auth/token_store"

module K8y
  module REST
    class Connection
      extend Forwardable

      attr_reader :base_path, :connection
      attr_accessor :token_store

      VERBS = [:get, :post, :put, :patch, :delete]
      def_delegators(:connection, *VERBS)

      class << self
        # Initialize a Connection object using a provided REST::Config instance
        def from_config(config)
          new(base_path: config.base_path, ssl: config.transport.to_faraday_options, auth: config.auth)
        end
      end

      def initialize(base_path:, ssl:, auth:, &conn_options)
        @base_path = base_path
        @auth = auth
        @connection = Faraday.new(base_path, ssl: ssl) do |connection|
          connection.use(Faraday::Response::RaiseError)
          FaradaySettings.configure_connection(connection)
          auth.configure_connection(connection)
          yield connection if block_given?
        end
      end

      def generate_token!
        auth.generate_token!(self) if auth.respond_to?(:generate_token!)
      end

      def host
        URI(base_path).host
      end

      private

      attr_reader :auth
    end
  end
end
