# frozen_string_literal: true

require_relative "api"
require_relative "resource_description"

require "json"

module KubeclientNext
  module Client
    class APIBuilder < Module
      attr_reader :api, :client

      VERBS_TO_METHODS = {
        create: :define_create_resource,
        delete: :define_delete_resource,
        get: :define_get_resource,
        list: :define_get_resources,
        patch: :define_patch_and_apply_resource,
        update: :define_update_resource,
      }

      def initialize(api:, client:)
        super()
        @api = api
        @client = client
      end

      def build!
        rest_client = RESTClient.new(config: client.config, context: client.context.name,
          path: api.path)
        response = rest_client.get
        resource_descriptions = JSON.parse(response.body)["resources"].map do |resource_description|
          ResourceDescription.from_hash(resource_description)
        end

        resource_descriptions.each do |resource_description|
          next if resource_description.subresource?

          VERBS_TO_METHODS
            .filter { |verb, _| resource_description.has_verb?(verb) }
            .each_value { |method| send(method, client, rest_client, resource_description) }
        end
      end

      private

      # TODO: handle response errors (do this in RESTClient...)
      # TODO: handle ArgumentErrors for expected kwargs for each type of method
      # TODO: what kind of objects to return:
      #   (Recursive Open Struct or user-provided class that supports unmarshalling?)
      # TODO: register method names in APIs and check to avoid conflicts (we assume this will be a rarity)
      def define_create_resource(client, rest_client, resource_description)
        client.define_singleton_method("create_#{resource_description.singular_name}".to_sym) do |kwargs = {}|
          namespace = kwargs.fetch(:namespace) if resource_description.namespaced
          data = kwargs.fetch(:data)
          headers = kwargs.fetch(:headers, {})
          rest_client.post(resource_description.path_for_resources(namespace: namespace),
            data: JSON.dump(data), headers: headers)
        end
      end

      def define_delete_resource(client, rest_client, resource_description)
        client.define_singleton_method("delete_#{resource_description.singular_name}".to_sym) do |kwargs = {}|
          namespace = kwargs.fetch(:namespace) if resource_description.namespaced
          name = kwargs.fetch(:name)
          headers = kwargs.fetch(:headers, {})
          rest_client.delete(resource_description.path_for_resource(namespace: namespace, name: name),
            headers: headers)
        end
      end

      def define_get_resource(client, rest_client, resource_description)
        client.define_singleton_method("get_#{resource_description.singular_name}".to_sym) do |kwargs = {}|
          namespace = kwargs.fetch(:namespace) if resource_description.namespaced
          name = kwargs.fetch(:name)
          headers = kwargs.fetch(:headers, {})
          rest_client.get(resource_description.path_for_resource(namespace: namespace, name: name), headers: headers)
        end
      end

      def define_get_resources(client, rest_client, resource_description)
        client.define_singleton_method("get_#{resource_description.plural_name}".to_sym) do |kwargs = {}|
          namespace = kwargs.fetch(:namespace) if resource_description.namespaced
          headers = kwargs.fetch(:headers, {})
          rest_client.get(resource_description.path_for_resources(namespace: namespace), headers: headers)
        end
      end

      def define_patch_and_apply_resource(client, rest_client, resource_description)
        define_patch_resource(client, rest_client, resource_description)
        define_apply_resource(client, rest_client, resource_description)
      end

      def define_patch_resource(client, rest_client, resource_description)
        client.define_singleton_method("patch_#{resource_description.singular_name}".to_sym) do |kwargs = {}|
          namespace = kwargs.fetch(:namespace) if resource_description.namespaced
          name = kwargs.fetch(:name)
          data = kwargs.fetch(:data)
          strategy = kwargs.fetch(:strategy)
          headers = kwargs.fetch(:headers, {}).merge(content_type_for_patch_strategy(strategy))
          rest_client.patch(resource_description.path_for_resource(namespace: namespace, name: name),
            strategy: strategy, data: JSON.dump(data), headers: headers)
        end
      end

      def define_apply_resource(client, rest_client, resource_description)
        # TODO: apply is really a special-case of patch, but requires a bit more effort to implement...
      end

      def define_update_resource(client, rest_client, resource_description)
        client.define_singleton_method("update_#{resource_description.singular_name}".to_sym) do |kwargs = {}|
          namespace = kwargs.fetch(:namespace) if resource_description.namespaced
          name = kwargs.fetch(:name)
          data = kwargs.fetch(:data)
          headers = kwargs.fetch(:headers, {})
          rest_client.put(resource_description.path_for_resource(namespace: namespace, name: name),
            data: JSON.dump(data), headers: headers)
        end
      end

      def content_type_for_patch_strategy(strategy)
        case strategy
        when :json
          "application/json-patch+json"
        when :merge
          "application/merge-patch+json"
        when :strategic_merge
          "application/strategic-merge-patch+json"
        else
          raise ArgumentError, "unknown patch strategy: #{strategy}. Acceptable strategies are" \
            " :apply, :json, :merge, or :strategic_merge"
        end
      end
    end
  end
end
