# frozen_string_literal: true

require_relative "rest_client"
require_relative "api_builder"
require_relative "apis"

module KubeclientNext
  module Client
    class Client
      ContextNotFoundError = Class.new(Error)
      APINameConflictError = Class.new(Error)

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
        apis.each { |api| APIBuilder.new(api: api, config: config, context: context.name).build! }
      end

      def set_context(context_name)
        @context = config.context(context_name)
      end

      def method_missing(method_name, *args, &block)
        candidate_apis = apis.apis_for_method(method_name)
        case candidate_apis.length
        when 0
          super
        when 1
          public_send(candidate_apis.first, args, &block)
        else
          raise APINameConflictError, "#{method_name} is defined in multiple group versions: " \
            "#{candidate_apis.map(&:group_version).join(", ")}. You can access a specific GroupVersion " \
            "by declaring it explicitly. E.g. client.apis.core_v1.get_pods"
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        # TODO: once bundle install works use #present? here
        # apis.apis_for_method(method_name).present? || super
        apis.any? { |api| api.has_api_method?(method_name) } || super
      end
    end
  end
end
