# frozen_string_literal: true

require_relative "api"
require_relative "resource_description"

require "json"

module KubeclientNext
  module Client
    class APIBuilder < Module
      METHOD_PREFIXES = ["get"] # watch delete create update patch json_patch merge_patch apply).freeze

      attr_reader :api, :client

      # TODO: bad name, perhaps class method with better intention...
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
        # On the right track, just need to actually massage the resources into proper API paths and define all the
        # methods that we want. Let's start with `get` singular, then go from there.
        resource_descriptions.each do |resource_description|
          # We need to raise if the method already exists on the client.
          # It would be nice if we could x-reference where it was made: we can do so by
          # making a memo in each API object of each `kind` it discovers. Then, handle the error in `Client`

          # TODO: is there a nice way to programatically handle these? Looks like all the info we need is there
          next if resource_description.subresource?

          define_get_resources(client, rest_client, resource_description)
          define_get_resource(client, rest_client, resource_description)
        end
      end

      # TODO: handle response errors (do this in RESTClient...)
      # TODO: handle ArgumentErrors for expected kwargs for each type of method
      # TODO: what kind of objects to return:
      #   (Recursive Open Struct or user-provided class that supports unmarshalling?)
      # TODO: register method names in APIs and check to avoid conflicts (we assume this will be a rarity)
      def define_get_resources(client, rest_client, resource_description)
        client.define_singleton_method("get_#{resource_description.plural_name}".to_sym) do |kwargs = {}|
          namespace = kwargs[:namespace] if resource_description.namespaced
          rest_client.get(resource_description.path_for_resources(namespace: namespace))
        end
      end

      def define_get_resource(client, rest_client, resource_description)
        client.define_singleton_method("get_#{resource_description.singular_name}".to_sym) do |kwargs = {}|
          namespace = kwargs[:namespace] if resource_description.namespaced
          name = kwargs.fetch(:name)
          rest_client.get(resource_description.path_for_resource(namespace: namespace, name: name))
        end
      end
    end
  end
end
