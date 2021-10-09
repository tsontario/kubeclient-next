# frozen_string_literal: true

require "test_helper"

module K8y
  module REST
    class TokenRefreshTest < TestCase
      def test_attempt_regenerate_token_on_401_request_then_raise_401_if_token_still_invalid
      end
    end
  end
end
