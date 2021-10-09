# frozen_string_literal: true

module K8y
  module REST
    module Auth
      class TokenStore
        class << self
          def [](hostname)
            store[hostname]
          end

          def []=(hostname, token)
            store[hostname] = token
          end

          private

          def store
            @store ||= {}
          end
        end
      end
    end
  end
end
