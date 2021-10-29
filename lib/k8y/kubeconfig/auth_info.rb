# frozen_string_literal: true

require_relative "auth_provider"

module K8y
  module Kubeconfig
    class AuthInfo
      attr_reader :client_certificate, :client_certificate_data, :client_key, :client_key_data, :token, :token_file,
        :as, :as_groups, :as_user_extra, :username, :password, :auth_provider, :exec_options, :extensions,
        def self.from_hash(hash)
          new(
            client_certificate: hash.fetch("client-certificate", nil),
            client_certificate_data: hash.fetch("client-certificate-data", nil),
            client_key: hash.fetch("client-key", nil),
            client_key_data: hash.fetch("client-key-data", nil),
            token: hash.fetch("token", nil),
            token_file: hash.fetch("tokenFile", nil),
            as: hash.fetch("as", nil),
            as_groups: hash.fetch("as-groups", nil),
            as_user_extra: hash.fetch("as-user-extra", nil),
            username: hash.fetch("username", nil),
            password: hash.fetch("password", nil),
            auth_provider: AuthProvider.new(hash.fetch("auth-provider", nil)),
            exec_options: hash.fetch("exec", nil),
            extensions: hash.fetch("extensions", nil)
          )
        end

      def initialize(client_certificate: nil, client_certificate_data: nil, client_key: nil, client_key_data: nil,
        token: nil, token_file: nil, as: nil, as_groups: nil, as_user_extra: nil, username: nil, password: nil,
        auth_provider: nil, exec_options: nil, extensions: nil)
        @client_certificate = client_certificate
        @client_certificate_data = client_certificate_data
        @client_key = client_key
        @client_key_data = client_key_data
        @token = token
        @token_file = token_file
        @as = as
        @as_groups = as_groups
        @as_user_extra = as_user_extra
        @username = username
        @password = password
        @auth_provider = auth_provider
        @exec_options = exec_options
        @extensions = extensions
      end
    end
  end
end
