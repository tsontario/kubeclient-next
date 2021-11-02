# frozen_string_literal: true

module K8y
  module Client
    # ResourceDescription represents the resource information for a given GroupVersion
    class ResourceDescription
      attr_reader :name, :kind, :namespaced, :verbs
      alias_method(:plural_name, :name)

      # Creates a new ResourceDescription from a Hash. Expected to be provided as part of a JSON
      # response from the API server.
      #
      # @param [Hash] hash
      def self.from_hash(hash)
        new(
          name: hash.fetch("name"),
          kind: hash.fetch("kind"),
          singular_name: hash.fetch("singularName"),
          namespaced: hash.fetch("namespaced"),
          verbs: hash.fetch("verbs").map(&:to_sym),
        )
      end

      # Creates a ResourceDescription.
      #
      # @param [String] name
      #   The name of the resource (e.g. pods).
      # @param [String] kind
      #   The kind of the resource.
      # @param [String] singular_name
      #   The singular name of this resource.
      # @param [Bool] namespaced
      #   Whether or not the resource is namespaced.
      # @param [[String]] verbs
      #   Verbs supported by the resource.
      def initialize(name:, kind:, singular_name:, namespaced:, verbs:)
        @name = name
        @kind = kind
        @singular_name = singular_name
        @namespaced = namespaced
        @verbs = verbs
      end

      # Returns the singular name of the resource, or the empty string if not present
      #
      # @return [String]
      def singular_name
        if @singular_name.empty?
          kind.downcase
        else
          @singular_name
        end
      end

      # Returns true if the resource is a subresource.
      # E.g. namespaces/status, deployments/scale, etc.
      #
      # @return [Bool]
      def subresource?
        name.include?("/")
      end

      # Returns true if the resource supports a given verb.
      #
      # @param [String] verb
      # @return [Bool]
      def has_verb?(verb)
        verbs.include?(verb)
      end

      # Return the subpath for the resource.
      #
      # @param [String] namespace
      #   The name of the namespace, if it exists.
      # @return [String]
      def path_for_resources(namespace: nil)
        if namespace
          "namespaces/#{namespace}/#{plural_name}"
        else
          plural_name
        end
      end

      # Return the subpath for an instance of the resource.
      #
      # @param [String] namespace
      #   The name of the namespace, if it exists.
      # @param [String] name
      #   The name of the resource instance
      # @return [String]
      def path_for_resource(namespace: nil, name:)
        "#{path_for_resources(namespace: namespace)}/#{name}"
      end
    end
  end
end
