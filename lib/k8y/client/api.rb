# frozen_string_literal: true

require "forwardable"

module K8y
  module Client
    class API
      extend Forwardable

      attr_reader :group_version

      def_delegators(:@group_version, :group, :version)

      def initialize(group_version:)
        @group_version = group_version
        @discovered = false
        @api_methods = {}
      end

      def discovered?
        discovered
      end

      def has_api_method?(method)
        api_methods.dig(method)
      end

      # Core/v1 resources are in `/api/#{version}`. In general, all other resources are found in `/apis/GROUP/VERSION`
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
