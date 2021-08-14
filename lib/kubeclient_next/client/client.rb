# frozen_string_literal: true

require_relative "rest_client"
require_relative "api_builder"
require_relative "apis"

module KubeclientNext
  module Client
    class Client
      ContextNotFoundError = Class.new(Error)

      DEFAULT_GROUP_VERSIONS = [
        GroupVersion.new(group: "core", version: "v1"),
        GroupVersion.new(group: "apps", version: "v1"),
      ]

      attr_reader :config, :context, :apis

      def initialize(config:, context:, group_versions: DEFAULT_GROUP_VERSIONS)
        @config = config
        @context = config.context(context)
        @apis = APIs.new(group_versions: group_versions)
      end

      def discover!
        apis.each { |_, api| APIBuilder.new(api: api, client: self) }
      end

      def set_context(context_name)
        @context = config.context(context_name)
      end
    end
  end
end
