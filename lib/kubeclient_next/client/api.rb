# frozen_string_literal: true

require "forwardable"

module KubeclientNext
  module Client
    class API
      extend Forwardable

      attr_reader :group_version

      def_delegators(:@group_version, :group, :version)

      def initialize(group_version:)
        @group_version = group_version
        @discovered = false
      end

      def discovered?
        @discovered
      end
    end
  end
end
