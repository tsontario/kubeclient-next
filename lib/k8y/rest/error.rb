# frozen_string_literal: true
module K8y
  module REST
    Error = Class.new(Error)

    HTTPError = Class.new(Error)
    ClientError = Class.new(HTTPError)
    NotFoundError = Class.new(ClientError)
    UnauthorizedError = Class.new(ClientError)
    ServerError = Class.new(HTTPError)
  end
end
