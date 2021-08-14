# frozen_string_literal: true
module KubeclientNext
  module Client
    class ResourceDescription
      attr_reader :name, :kind, :namespaced, :verbs
      def self.from_hash(hash)
        new(
          name: hash.fetch("name"),
          kind: hash.fetch("kind"),
          singular_name: hash.fetch("singularName"),
          namespaced: hash.fetch("namespaced"),
          verbs: hash.fetch("verbs"),
        )
      end

      def initialize(name:, kind:, singular_name:, namespaced:, verbs:)
        @name = name
        @kind = kind
        @singular_name = singular_name
        @namespaced = namespaced
        @verbs = verbs
      end

      def singular_name
        if @singular_name.empty?
          kind.downcase
        else
          @singular_name
        end
      end

      def plural_name
        name
      end

      def subresource?
        name.include?("/") # E.g. namespaces/status, deployments/scale, etc.
      end

      def path_for_resources(namespace:)
        if namespace
          "namespaces/#{namespace}/#{plural_name}"
        else
          plural_name.to_s
        end
      end

      def path_for_resource(namespace:, name:)
        "#{path_for_resources(namespace: namespace)}/#{name}"
      end
    end
  end
end
