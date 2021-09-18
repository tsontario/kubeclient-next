# frozen_string_literal: true

module K8y
  module Client
    class ResourceDescription
      attr_reader :name, :kind, :namespaced, :verbs
      alias_method(:plural_name, :name)

      def self.from_hash(hash)
        new(
          name: hash.fetch("name"),
          kind: hash.fetch("kind"),
          singular_name: hash.fetch("singularName"),
          namespaced: hash.fetch("namespaced"),
          verbs: hash.fetch("verbs").map(&:to_sym),
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

      def subresource?
        name.include?("/") # E.g. namespaces/status, deployments/scale, etc.
      end

      def has_verb?(verb)
        verbs.include?(verb)
      end

      def path_for_resources(namespace: nil)
        if namespace
          "namespaces/#{namespace}/#{plural_name}"
        else
          plural_name
        end
      end

      def path_for_resource(namespace: nil, name:)
        "#{path_for_resources(namespace: namespace)}/#{name}"
      end
    end
  end
end
