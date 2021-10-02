# frozen_string_literal: true

module K8y
  module Auth
    class ProviderBase
      def token
        raise NotImplementedError
      end
    end
  end
end
