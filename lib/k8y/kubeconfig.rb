# frozen_string_literal: true

require_relative "kubeconfig/config"

module K8y
  module Kubeconfig
    Error = Class.new(Error)
    NotInClusterError = Class.new(Error)

    IN_CLUSTER_NAME = "in-cluster"

    TOKEN_FILE = "/var/run/secrets/kubernetes.io/serviceaccount/token"
    ROOT_CA_FILE = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"

    def self.from_file(file = File.open(ENV["KUBECONFIG"]))
      hash = YAML.safe_load(file.read, permitted_classes: [Date, Time])
      Config.from_hash(hash)
    end

    def self.in_cluster_config
      host = ENV["KUBERNETES_SERVICE_HOST"]
      port = ENV["KUBERNETES_SERVICE_PORT"]
      raise NotInClusterError unless host && port

      token_data = File.read(TOKEN_FILE)
      auth_info = AuthInfo.new(token: token_data, token_file: TOKEN_FILE)
      user = User.new(
        name: IN_CLUSTER_NAME,
        auth_info: auth_info
      )

      ca_data = File.read(ROOT_CA_FILE)
      cluster = Cluster.new(
        name: IN_CLUSTER_NAME,
        insecure_skip_tls_verify: false,
        certificate_authority: nil,
        certificate_authority_data: ca_data,
        server: "https://#{host}:#{port}",
      )
      context = Context.new(
        name: IN_CLUSTER_NAME,
        cluster: IN_CLUSTER_NAME,
        namespace: nil,
        user: IN_CLUSTER_NAME
      )

      Config.new(
        clusters: [cluster],
        contexts: [context],
        current_context: context,
        users: [user]
      )
    end
  end
end
