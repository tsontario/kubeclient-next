# frozen_string_literal: true

require "faraday"
require "base64"

require_relative "config"
require_relative "connection"
require_relative "request_wrapper"
require_relative "response_formatter"

module K8y
  module REST
    class Client
      attr_reader :connection

      class << self
        def from_config(config)
          new(
            connection: Connection.new(
              host: config.host,
              ssl: config.transport.to_faraday_options,
              auth: config.auth
            )
          )
        end
      end

      def host
        connection.host
      end

      def initialize(connection:)
        @connection = connection
        @request_wrapper = RequestWrapper.new(self)
      end

      def get(path = "", headers: {}, as: :ros)
        with_wrapper do
          response = connection.get(formatted_uri(path))
          format_response(response, as: as)
        end
      end

      def post(path = "", data:, headers: {}, as: :ros)
        with_wrapper do
          response = connection.post(formatted_uri(path), data, headers)
          format_response(response, as: as)
        end
      end

      def put(path = "", data:, headers: {}, as: :ros)
        with_wrapper do
          response = connection.put(formatted_uri(path), data, headers)
          format_response(response, as: as)
        end
      end

      def patch(path = "", strategy:, data:, headers: {}, as: :ros)
        with_wrapper do
          response = connection.patch(formatted_uri(path), data, headers)
          format_response(response, as: as)
        end
      end

      def delete(path = "", headers: {}, as: :ros)
        with_wrapper do
          response = connection.delete(formatted_uri(path))
          format_response(response, as: as)
        end
      end

      private

      attr_reader :request_wrapper

      def formatted_uri(path = "")
        File.join(connection.host, path)
      end

      def format_response(response, as: :ros)
        ResponseFormatter.new(response).format(as: as)
      end

      # I apologize for the ugly code, but it is relatively straightforward.
      # If the request returns an Unauthorized response, try generating a new token and retry the request.
      # If that fails, raise the error to the caller as normal.
      def with_wrapper(&block)
        begin
          begin
            yield
          rescue Faraday::Error => e
            request_wrapper.handle(e)
          end

        rescue UnauthorizedError
          connection.generate_token!
          yield
        end
      rescue Faraday::Error => e
        request_wrapper.handle(e)
      end
    end
  end
end
