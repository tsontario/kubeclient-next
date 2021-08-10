# frozen_string_literal: true

require_relative "api"

require "json"

module KubeclientNext
  module Client
    class APIBuilder < Module
      def initialize(api:, client:)
        super()
        @rest_client = RESTClient.new(config: client.config, context: client.context.name,
          group: api.group, version: api.version)
        response = @rest_client.get
        resources = JSON.parse(response.body)["resources"]
        # On the right track, just need to actually massage the resources into proper API paths and define all the
        # methods that we want. Let's start with `get` singular, then go from there.
        resources.each do |resource|
          # We need to raise if the method already exists on the client.
          # It would be nice if we could x-reference where it was made: we can do so by
          # making a memo in each API object of each `kind` it discovers. Then, handle the error in `Client`
          client.define_singleton_method("get_#{resource["kind"]}".to_sym) { puts "In get_#{resource["kind"]}!" }
        end
      end
    end
  end
end
