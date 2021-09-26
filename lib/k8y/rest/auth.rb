# frozen_string_literal: true
module K8y
  module REST
    # Auth encapsulates information/behaviour used to authenticate against a server
    class Auth
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
          # TODO: custom object
        end

        def exec_provider(auth_info)
          # TODO: custom object
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
    end
  end
end
