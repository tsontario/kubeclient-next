# frozen_string_literal: true

require "faraday"
require "base64"
require "recursive_open_struct"

require_relative "config"
require_relative "connection"
require_relative "response_formatter"

module K8y
  module REST
    class Client
      attr_reader :connection

      class << self
        def from_config(config)
          new(Connection.new(host: config.host, ssl: {}, auth: config.auth))
        end
      end

      def initialize(connection:)
        @connection = connection
      end

      def host
        @host ||= if "#{connection.host}".end_with?("/")
          connection.host
        else
          URI.join(connection.host, "/")
        end
      end

      def get(path = "", headers: {}, as: :ros)
        response = connection.get(formatted_uri(path))
        format_response(response, as: as)
      end

      def post(path = "", data:, headers: {}, as: :ros)
        response = connection.post(formatted_uri(path), data, headers)
        format_response(response, as: as)
      end

      def put(path = "", data:, headers: {}, as: :ros)
        response = connection.put(formatted_uri(path), data, headers)
        format_response(response, as: as)
      end

      def patch(path = "", strategy:, data:, headers: {}, as: :ros)
        response = connection.patch(formatted_uri(path), data, headers)
        format_response(response, as: as)
      end

      def delete(path = "", headers: {}, as: :ros)
        response = connection.delete(formatted_uri(path))
        format_response(response, as: as)
      end

      private

      def formatted_uri(path = "")
        URI.join(host, path)
      end

      def format_response(response, as: :ros)
        ResponseFormatter.new(response).format(as: as)
      end
    end
  end
end
