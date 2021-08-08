# frozen_string_literal: true
require_relative "rest_client"

module KubeclientNext
  module Clients
    class Client
      attr_reader :config
      attr_accessor :context, :group, :version

      def initialize(config:, context: nil, group: nil, version: nil)
        @config = config
        @context = context
        @group = group
        @version = version
      end

      def get_events(namespace: @context.namespace)
        # Just some ideas of a possible generic way to deal with group-versions.
        # Recall a key idea is to be able to use a single client instance to access multiple gvks.
        # For now, however, we're going to build the simplest thing we can: explicitly getting a single resource.
        # rest_client = RESTClientFactory.client_for(group: @group, version: @version)
        # rest_client_for()
        rest_client = RESTClient.new(url: config.clusters.first.server, group: nil, version: "v1")
        response = rest_client.get_events(namespace: "default")
        puts response
      end
    end
  end
end
