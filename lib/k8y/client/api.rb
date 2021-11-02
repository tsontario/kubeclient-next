# frozen_string_literal: true

require "forwardable"

module K8y
  module Client
    # API objects represent resources defined by a single GroupVersion.
    # Upon discovery, client methods are generated on API instances.
    #
    # API should be considered an internal class and its public methods should _not_ be considered stable.
    class API
      extend Forwardable

      attr_reader :group_version

      def_delegators(:@group_version, :group, :version)

      # Creates an API object.
      #
      # @param [K8y::GroupVersion] group_version
      #   A GroupVersion.
      def initialize(group_version:)
        @group_version = group_version
        @discovered = false
        @api_methods = {}
      end

      #   Returns whether or not discovery has occurred.
      # @return [Bool]
      def discovered?
        discovered
      end

      # Determines whether the API instance has a given client method.
      # @param [Symbol] method
      #   The name of the method to query.
      # @return [Bool]
      def has_api_method?(method)
        api_methods.dig(method)
      end

      # Returns the API server path associated with the instance.
      # Note: Core/v1 resources are in `/api/#{version}`.
      # In general, all other resources are found in `/apis/GROUP/VERSION`.
      #
      # @return [String]
      def path
        @path ||= if group == "core"
          "/api/#{version}"
        else
          "/apis/#{group}/#{version}"
        end
      end

      private

      attr_accessor :api_methods, :discovered

      def register_method(method)
        api_methods[method] = true
      end
    end
  end
end
