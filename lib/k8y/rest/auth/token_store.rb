# frozen_string_literal: true

module K8y
  module REST
    module Auth
      class TokenStore
        class << self
          def [](hostname)
            lock.synchronize { store[hostname] }
          end

          def []=(hostname, token)
            lock.synchronize { store[hostname] = token }
          end

          private

          def store
            @store ||= {}
          end

          def lock
            @lock ||= Mutext.new
          end
        end
      end
    end
  end
end
