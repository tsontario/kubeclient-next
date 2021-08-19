# frozen_string_literal: true

require_relative "api"
require_relative "resource_description"

require "json"

module KubeclientNext
  module Client
    class APIBuilder < Module
      attr_reader :api, :config, :context

      VERBS_TO_METHODS = {
        create: :define_create_resource,
        delete: :define_delete_resource,
        get: :define_get_resource,
        list: :define_get_resources,
        patch: :define_patch_and_apply_resource,
        update: :define_update_resource,
      }

      GENERATED_METHOD_PREFIXES = [
        "create_",
        "delete_",
        "get_",
        "patch_",
        "apply_",
        "update_",
      ]

      def initialize(api:, config:, context:)
        super()
        @api = api
        @config = config
        @context = context
      end

      def build!
        rest_client = RESTClient.new(config: config, context: context, path: api.path)
        response = rest_client.get(as: :raw)
        resource_descriptions = JSON.parse(response.body)["resources"].map do |resource_description|
          ResourceDescription.from_hash(resource_description)
        end

        resource_descriptions.each do |resource_description|
          next if resource_description.subresource?

          VERBS_TO_METHODS
            .filter { |verb, _| resource_description.has_verb?(verb) }
            .each_value { |method| send(method, api, rest_client, resource_description) }
          api.instance_eval { self.discovered = true }
        end
      end

      private

      def define_create_resource(api, rest_client, resource_description)
        method_name = "create_#{resource_description.singular_name}".to_sym
        api.instance_eval do
          define_singleton_method(method_name) do |kwargs = {}|
            namespace = kwargs.fetch(:namespace) if resource_description.namespaced
            data = kwargs.fetch(:data)
            headers = kwargs.fetch(:headers, {})
            rest_client.post(resource_description.path_for_resources(namespace: namespace),
              data: JSON.dump(data), headers: headers)
          end
          register_method(method_name)
        end
      end

      def define_delete_resource(api, rest_client, resource_description)
        method_name = "delete_#{resource_description.singular_name}".to_sym
        api.instance_eval do
          define_singleton_method(method_name) do |kwargs = {}|
            namespace = kwargs.fetch(:namespace) if resource_description.namespaced
            name = kwargs.fetch(:name)
            headers = kwargs.fetch(:headers, {})
            rest_client.delete(resource_description.path_for_resource(namespace: namespace, name: name),
              headers: headers)
          end
          register_method(method_name)
        end
      end

      def define_get_resource(api, rest_client, resource_description)
        method_name = "get_#{resource_description.singular_name}".to_sym
        api.instance_eval do
          define_singleton_method(method_name) do |kwargs = {}|
            namespace = kwargs.fetch(:namespace) if resource_description.namespaced
            name = kwargs.fetch(:name)
            headers = kwargs.fetch(:headers, {})
            rest_client.get(resource_description.path_for_resource(namespace: namespace, name: name), headers: headers)
          end
          register_method(method_name)
        end
      end

      def define_get_resources(api, rest_client, resource_description)
        method_name = "get_#{resource_description.plural_name}".to_sym
        api.instance_eval do
          define_singleton_method(method_name) do |kwargs = {}|
            namespace = kwargs.fetch(:namespace) if resource_description.namespaced
            headers = kwargs.fetch(:headers, {})
            rest_client.get(resource_description.path_for_resources(namespace: namespace), headers: headers)
          end
          register_method(method_name)
        end
      end

      def define_patch_and_apply_resource(api, rest_client, resource_description)
        define_patch_resource(api, rest_client, resource_description)
        define_apply_resource(api, rest_client, resource_description)
      end

      def define_patch_resource(api, rest_client, resource_description)
        method_name = "patch_#{resource_description.singular_name}".to_sym
        # Lexically scope this method in the block to make it available inside the closure when invoked by client
        scoped_content_type_for_patch_strategy = proc { |strategy| content_type_for_patch_strategy(strategy) }
        api.instance_eval do
          define_singleton_method(method_name) do |kwargs = {}|
            namespace = kwargs.fetch(:namespace) if resource_description.namespaced
            name = kwargs.fetch(:name)
            data = kwargs.fetch(:data)
            strategy = kwargs.fetch(:strategy)
            headers = kwargs.fetch(:headers, {}).merge(scoped_content_type_for_patch_strategy.call(strategy))
            rest_client.patch(resource_description.path_for_resource(namespace: namespace, name: name),
              strategy: strategy, data: JSON.dump(data), headers: headers)
          end
          register_method(method_name)
        end
      end

      def define_apply_resource(api, rest_client, resource_description)
        # method_name = TODO method name
        # # TODO: apply is really a special-case of patch, but requires a bit more effort to implement...
        # api.register_method(method_name)
      end

      def define_update_resource(api, rest_client, resource_description)
        method_name = "update_#{resource_description.singular_name}".to_sym
        api.instance_eval do
          api.define_singleton_method(method_name) do |kwargs = {}|
            namespace = kwargs.fetch(:namespace) if resource_description.namespaced
            name = kwargs.fetch(:name)
            data = kwargs.fetch(:data)
            headers = kwargs.fetch(:headers, {})
            rest_client.put(resource_description.path_for_resource(namespace: namespace, name: name),
              data: JSON.dump(data), headers: headers)
          end
          register_method(method_name)
        end
      end

      def content_type_for_patch_strategy(strategy)
        case strategy
        when :json
          { "Content-Type": "application/json-patch+json" }
        when :merge
          { "Content-Type": "application/merge-patch+json" }
        when :strategic_merge
          { "Content-Type": "application/strategic-merge-patch+json" }
        else
          raise ArgumentError, "unknown patch strategy: #{strategy}. Acceptable strategies are" \
            " :json, :merge, or :strategic_merge"
        end
      end
    end
  end
end
