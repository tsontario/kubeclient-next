# frozen_string_literal: true

require "test_helper"

module K8y
  module REST
    class RequestWrapperTest < TestCase
      class TestException < Faraday::Error
        attr_reader :response_status

        def initialize(response_status)
          super(self)
          @response_status = response_status
        end
      end

      def setup
        @request_wrapper = RequestWrapper.new
      end

      def test_handle_returns_server_error_on_5xx_error
        exception = TestException.new(500)
        assert_raises(ServerError) { @request_wrapper.handle(exception) }
      end

      def test_handle_returns_retriable_error_if_retriable_and_401
        exception = TestException.new(401)
        assert_raises(RetriableUnauthorizedError) { @request_wrapper.handle(exception, retry_unauthorized: true) }
      end

      def test_handle_returns_unauthorized_error_if_not_retriable_and_401
        exception = TestException.new(401)
        assert_raises(UnauthorizedError) { @request_wrapper.handle(exception) }
      end

      def test_handle_returns_not_found_error_when_404
        exception = TestException.new(404)
        assert_raises(NotFoundError) { @request_wrapper.handle(exception) }
      end

      def test_handle_returns_generic_error_on_unspecified_error
        exception = TestException.new(410)
        assert_raises(HTTPError) { @request_wrapper.handle(exception) }
      end
    end
  end
end
