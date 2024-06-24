# frozen_string_literal: true

require_relative "api"

module K8y
  module Client
    # APIs represent a collection of API objects.
    #
    # APIs should be considered an internal class and its public methods should _not_ be considered stable.
    class APIs
      include Enumerable
      # Creates an APIs instance.
      #
      # @param [[K8y::GroupVersion]] group_versions
      #   A list of GroupVersions.
      def initialize(group_versions:)
        @apis = group_versions.each_with_object({}) do |gv, acc|
          api = API.new(group_version: gv)
          acc[gv.to_s] = api
          define_singleton_method(gv.to_method_name) { api }
        end
      end

      # Returns all APIs that define the given method.
      #
      # @param [Symbol] method
      #   The API method to search for.
      def apis_for_method(method)
        select { |api| api.has_api_method?(method) }
      end

      def each(&block)
        apis.each { |_, api| yield(api) }
      end

      private

      attr_reader :apis
    end
  end
end
