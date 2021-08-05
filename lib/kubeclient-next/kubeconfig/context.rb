# frozen_string_literal: true

module KubeclientNext
  module Kubeconfig
    class Context
      attr_reader :name, :cluster, :namespace, :user

      def self.from_hash(hash)
        context = hash.fetch("context")
        new(
          name: hash.fetch("name"),
          cluster: context.fetch("cluster"),
          namespace: context.fetch("namespace", nil),
          user: context.fetch("user")
        )
      end

      def initialize(name:, cluster:, namespace:, user:)
        @name = name
        @cluster = cluster
        @namespace = namespace
        @user = user
      end
    end
  end
end
