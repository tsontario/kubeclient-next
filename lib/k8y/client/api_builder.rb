# frozen_string_literal: true

require_relative "api"
require_relative "resource_description"

require "json"

module K8y
  module Client
    # APIBuilder objects perform the actual client discovery of a provided API. The provided API should
    # have a path that points to a collection of Kubernetes resources (that is, a valid GroupVersion path).
    #
    # APIBuilder should be considered an internal class and its API should _not_ be considered stable.
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

      GET_RESOURCES_OPTIONS = {
        label_selector: "labelSelector",
      }

      # Creates an APIBuilder object.
      #
      # @param [K8y::Client::API] api
      #   The API object on which to perform discovery.
      # @param [K8y::Kubeconfig::Config] config
      #   A Kubeconfig object.
      # @param [String] context
      #   The Kubernetes context name.
      def initialize(api:, config:, context:)
        super()
        @api = api
        @config = config
        @context = context
      end

      # Performs discovery and dynamically creates client methods on @api.
      def build!
        rest_config = REST::Config.from_kubeconfig(config, context: context, path: api.path)
        rest_client = REST::Client.new(connection: REST::Connection.from_config(rest_config))

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
        json_content_type = { "Content-Type": "application/json" }
        api.instance_eval do
          define_singleton_method(method_name) do |kwargs = {}|
            namespace = kwargs.fetch(:namespace) if resource_description.namespaced
            body = kwargs.fetch(:body)
            headers = kwargs.fetch(:headers, {}).merge(json_content_type)
            as = kwargs.fetch(:as, :ros)
            rest_client.post(resource_description.path_for_resources(namespace: namespace),
              body: JSON.dump(body), headers: headers, as: as)
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
            as = kwargs.fetch(:as, :ros)
            rest_client.delete(resource_description.path_for_resource(namespace: namespace, name: name), as: as)
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
            as = kwargs.fetch(:as, :ros)
            rest_client.get(resource_description.path_for_resource(namespace: namespace, name: name),
              headers: headers, as: as)
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
            params = {}
            ::K8y::Client::APIBuilder::GET_RESOURCES_OPTIONS.each do |opt, key|
              params[key] = kwargs[opt] if kwargs[opt]
            end
            as = kwargs.fetch(:as, :ros)
            rest_client.get(resource_description.path_for_resources(namespace: namespace), params: params,
              headers: headers, as: as)
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
            body = kwargs.fetch(:body)
            strategy = kwargs.fetch(:strategy)
            headers = kwargs.fetch(:headers, {}).merge(scoped_content_type_for_patch_strategy.call(strategy))
            as = kwargs.fetch(:as, :ros)
            rest_client.patch(resource_description.path_for_resource(namespace: namespace, name: name),
              strategy: strategy, body: JSON.dump(body), headers: headers, as: as)
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
        json_content_type = { "Content-Type": "application/json" }
        api.instance_eval do
          api.define_singleton_method(method_name) do |kwargs = {}|
            namespace = kwargs.fetch(:namespace) if resource_description.namespaced
            name = kwargs.fetch(:name)
            body = kwargs.fetch(:body)
            headers = kwargs.fetch(:headers, {}).merge(json_content_type)
            as = kwargs.fetch(:as, :ros)
            rest_client.put(resource_description.path_for_resource(namespace: namespace, name: name),
              body: JSON.dump(body), headers: headers, as: as)
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
