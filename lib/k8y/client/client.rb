# frozen_string_literal: true

require_relative "api_builder"
require_relative "apis"

module K8y
  module Client
    # Client provides the public entrypoint for using a high level REST API when interacting with your
    # Kubernetes cluster. It is a thin wrapper that forwards calls via #method_missing to lower-level
    # clients partitioned by GroupVersion.
    class Client
      attr_reader :config, :context, :apis

      # Creates a client object.
      #
      # @param [K8y::Kubeconfig::Config] config
      #   A Kubeconfig object containing information about how to to connect to a cluster
      # @param [String] context
      #   The name of the context to use for the client.
      # @param [[K8y::GroupVersion]] group_versions
      #   A list of GroupVersions that will be made accessible by the client.
      def initialize(config:, context:, group_versions: DEFAULT_GROUP_VERSIONS)
        @config = config
        @context = config.context(context)
        @apis = APIs.new(group_versions: group_versions)
      end

      # Performs discovery for each of the client's group_versions. Once called, REST methods will be
      # available to call on the client object (e.g. get_pods, update_configmap, etc.).
      def discover!
        apis.each { |api| APIBuilder.new(api: api, config: config, context: context.name).build! }
      end

      private

      # To allow a client to access multiple GroupVersions, each GroupVersion is encapsulated within
      # a dedicated API object. #method_missing is leveraged to know where a given method
      # should be forwarded.
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
