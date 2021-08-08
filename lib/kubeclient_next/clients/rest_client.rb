# frozen_string_literal: true
require "faraday"

module KubeclientNext
  module Clients
    class RESTClient
      attr_reader :url, :group, :version

      def initialize(url:, group:, version:)
        @url = url
        @group = group
        @version = version
        @connection = Faraday::Connection.new(endpoint)
      end

      def get_events(namespace:)
        puts @connection.get(URI.join(endpoint, "events"))
      end

      private

      attr_reader :connection

      def endpoint
        @endpoint ||= group ? URI.join(@url, @group, @version) : URI.join(@url, @version)
      end
    end
  end
end
