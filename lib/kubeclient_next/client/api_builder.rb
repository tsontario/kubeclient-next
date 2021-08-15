# frozen_string_literal: true

require_relative "api"
require_relative "resource_description"

require "json"

module KubeclientNext
  module Client
    class APIBuilder < Module
      attr_reader :api, :client

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

          define_get_resources(client, rest_client, resource_description)
          define_get_resource(client, rest_client, resource_description)
        end
      end

      private

      # TODO: handle response errors (do this in RESTClient...)
      # TODO: handle ArgumentErrors for expected kwargs for each type of method
      # TODO: what kind of objects to return:
      #   (Recursive Open Struct or user-provided class that supports unmarshalling?)
      # TODO: register method names in APIs and check to avoid conflicts (we assume this will be a rarity)
      def define_get_resources(client, rest_client, resource_description)
        client.define_singleton_method("get_#{resource_description.plural_name}".to_sym) do |kwargs = {}|
          namespace = kwargs.fetch(:namespace) if resource_description.namespaced
          rest_client.get(resource_description.path_for_resources(namespace: namespace))
        end
      end

      def define_get_resource(client, rest_client, resource_description)
        client.define_singleton_method("get_#{resource_description.singular_name}".to_sym) do |kwargs = {}|
          namespace = kwargs.fetch(:namespace) if resource_description.namespaced
          name = kwargs.fetch(:name)
          rest_client.get(resource_description.path_for_resource(namespace: namespace, name: name))
        end
      end
    end
  end
end
