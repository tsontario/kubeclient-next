# frozen_string_literal: true

require_relative "auth_info"

module K8y
  module Kubeconfig
    class User
      attr_reader :name, :auth_info

      def self.from_hash(hash)
        user = hash.fetch("user")
        new(
          name: hash.fetch("name"),
          auth_info: AuthInfo.from_hash(user)
        )
      end

      def initialize(name:, auth_info:)
        @name = name
        @auth_info = auth_info
      end
    end
  end
end
