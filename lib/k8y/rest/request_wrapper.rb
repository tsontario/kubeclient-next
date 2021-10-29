# frozen_string_literal: true

module K8y
  module REST
    class RequestWrapper
      def initialize(wrapped)
        @wrapped = wrapped
      end

      def handle(exception, retry_unauthorized: false)
        code = exception.response_status
        if code == 401 && retry_unauthorized
          raise RetriableUnauthorizedError, exception
        elsif code == 401
          raise UnauthorizedError, exception
        elsif code == 404
          raise NotFoundError, exception
        elsif code >= 500
          raise ServerError, exception
        else
          raise HTTPError, exception
        end
      end
    end
  end
end
