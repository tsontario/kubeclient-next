# frozen_string_literal: true
module K8y
  module REST
    class Auth
      InvalidAuthTypeError = Class.new(Error)

      class << self
        def from_kubeconfig(kubeconfig, context: nil)
          context = context ? context : kubeconfig.current_context
          auth_info = kubeconfig.user_for_context(context).auth_info

          new(token: token(auth_info), username: auth_info.username, password: auth_info.password,
            auth_provider: auth_provider(auth_info), exec_provider: exec_provider(auth_info))
        end

        private

        def token(auth_info)
          return auth_info.token if auth_info.token
          File.read(auth_info.token_file) if auth_info.token_file
        end

        def auth_provider(auth_info)
          # TODO
        end

        def exec_provider(auth_info)
          # TODO
        end
      end

      # TODO: this is one object that could be many kinds of auth... might be worth splitting into atomic pieces
      def initialize(token: nil, username: nil, password: nil, auth_provider: nil, exec_provider: nil)
        @token = token
        @username = username
        @password = password
        @auth_provider = auth_provider
        @exec_provider = exec_provider
      end

      def configure_connection(connection)
        case auth_type
        when :basic
          connection.basic_auth(username, password)
        when :token
          connection.headers[:Authorization] = "Bearer #{token}"
          # TODO...
        end
      end

      private

      attr_reader :token, :username, :password, :auth_provider, :exec_provider

      # TODO: these should be subclasses of abstract Auth class
      def auth_type
        if username && password
          :basic
        elsif token
          :token
        elsif auth_provider
          :auth_provider
        elsif exec_provider
          :exec_provider
        else
          :none
        end
      end

      def basic?
        auth_type == :basic
      end

      def token?
        auth_type == :token
      end
    end
  end
end
