# frozen_string_literal: true

require "yaml"
require_relative "cluster"
require_relative "context"
require_relative "user"

module K8y
  module Kubeconfig
    class Config
      ContextNotFoundError = Class.new(Error)
      ClusterNotFoundError = Class.new(Error)
      UserNotFoundError = Class.new(Error)

      attr_reader :api_version, :kind, :preferences, :clusters, :contexts, :users, :current_context

      def self.from_hash(hash)
        new(
          api_version: hash.fetch("apiVersion"),
          kind: hash.fetch("kind"),
          preferences: hash.fetch("preferences"),
          clusters: hash.fetch("clusters").map { |cluster| Cluster.from_hash(cluster) },
          contexts: hash.fetch("contexts").map { |context| Context.from_hash(context) },
          current_context: hash.fetch("current-context"),
          users: hash.fetch("users").map { |user| User.from_hash(user) },
        )
      rescue Psych::Exception, KeyError => e
        raise Error, e
      end

      def initialize(api_version: "v1", kind: "Config", preferences: {}, clusters:, contexts:, users:, current_context:)
        @api_version = api_version
        @kind = kind
        @preferences = preferences
        @clusters = clusters
        @contexts = contexts
        @users = users
        @current_context = current_context
      end

      def context(context)
        return context if context.is_a?(Context)

        context = contexts.find { |c| c.name == context }
        raise ContextNotFoundError, "Could not find context #{context} in config" unless context
        context
      end

      def cluster(name)
        cluster = clusters.find { |c| c.name == name }
        raise ClusterNotFoundError, "Could not find cluster #{name} in config" unless cluster
        cluster
      end

      def user(name)
        user = users.find { |user| user.name == name }
        raise UserNotFoundError, "User #{name} not found in config" unless user
        user
      end

      def cluster_for_context(context)
        cluster_name = context(context).cluster
        cluster(cluster_name)
      end

      def user_for_context(context)
        user(context(context).user)
      end
    end
  end
end
