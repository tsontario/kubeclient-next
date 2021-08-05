# frozen_string_literal: true
require "yaml"
require_relative "cluster"
require_relative "context"
require_relative "user"

module Kubeclient
  module Kubeconfig
    class Config
      attr_reader :api_version, :kind, :preferences, :clusters, :contexts, :users, :current_context


      def self.from_hash(hash)
        new(
          api_version: hash.fetch("apiVersion"),
          kind: hash.fetch("kind"),
          preferences: hash.fetch("preferences"),
          clusters: hash.fetch("clusters").map { |cluster| Cluster.from_hash(cluster) },
          contexts: hash.fetch("contexts").map { |context| Context.from_hash(context) },
          users: hash.fetch("users").map { |user| User.from_hash(user) },
          current_context: hash.fetch("current-context"),
        )
      rescue Psych::Exception, KeyError => e
        raise Error, e
      end

      def initialize(api_version:, kind:, preferences:, clusters:, contexts:, users:, current_context:)
        @api_version = api_version
        @kind = kind
        @preferences = preferences
        @clusters = clusters
        @contexts = contexts
        @users = users
        @current_context = current_context
      end
    end
  end
end
