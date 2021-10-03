# frozen_string_literal: true

module K8y
  module Auth
    module Providers
      class ProviderBase
        # TODO: public API not finalized; subject to change
        def token
          raise NotImplementedError
        end
      end
    end
  end
end
