# frozen_string_literal: true

require_relative "client/client"

module K8y
  # The Client module represents the highest-level API exposed by K8y. Client objects interact with clusters
  # using straightforward Kubernetes semantics.
  module Client
    Error = Class.new(Error)
    ContextNotFoundError = Class.new(Error)
    APINameConflictError = Class.new(Error)

    DEFAULT_GROUP_VERSIONS = [
      GroupVersion.new(group: "core", version: "v1"),
      GroupVersion.new(group: "apps", version: "v1"),
    ]

    # Generate a new K8y::Client::Client instance from a Kubeconfig.
    #
    # @param [K8y::Kubeconfig::Config] config
    #   A Kubeconfig instance.
    # @param [String] context
    #   The name of the context use. Defaults to the Kubeconfig's current context
    # @param [[K8y::GroupVersion]] group_versions
    #   The list of GroupVersions to use with the Client instance
    # @return [K8y::Client::Client]
    def self.from_config(config, context: nil, group_versions: DEFAULT_GROUP_VERSIONS)
      Client.new(config: config, context: context || config.current_context, group_versions: group_versions)
    end

    # Generate a new K8y::Client::Client instance using in-cluster parameters.
    #
    # @param [[K8y::GroupVersion]] group_versions
    #   The list of GroupVersions to use with the Client instance
    # @return [K8y::Client::Client]
    def self.from_in_cluster(group_versions: DEFAULT_GROUP_VERSIONS)
      config = Kubeconfig.in_cluster_config
      Client.new(config: config, context: Kubeconfig::IN_CLUSTER_NAME, group_versions: group_versions)
    end
  end
end
