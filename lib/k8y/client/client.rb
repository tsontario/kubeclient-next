# frozen_string_literal: true

require_relative "api_builder"
require_relative "apis"

module K8y
  module Client
    class Client
      attr_reader :config, :context, :apis

      def initialize(config:, context:, group_versions: DEFAULT_GROUP_VERSIONS)
        @config = config
        @context = config.context(context)
        @apis = APIs.new(group_versions: group_versions)
      end

      def discover!
        apis.each { |api| APIBuilder.new(api: api, config: config, context: context.name).build! }
      end

      def method_missing(method_name, *args, &block)
        candidate_apis = apis.apis_for_method(method_name)
        case candidate_apis.length
        when 0
          super
        when 1
          candidate_apis.first.public_send(method_name, *args, &block)
        else
          raise APINameConflictError, "#{method_name} is defined in multiple group versions: " \
            "#{candidate_apis.map(&:group_version).join(", ")}. You can access a specific GroupVersion " \
            "by declaring it explicitly. E.g. client.apis.core_v1.get_pods"
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        apis.apis_for_method(method_name).present? || super
      end
    end
  end
end
