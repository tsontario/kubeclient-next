# frozen_string_literal: true

require "test_helper"

module K8y
  module REST
    class ConnectionTest < TestCase
      # Not parallelizable due to FaradaySettings being a singleton
      def test_faraday_settings_are_configured_in_client_connection
        FaradaySettings.with_connection do |connection|
          connection.headers["FaradaySettings"] = "bogus"
        end
        connection = Connection.new(base_path: "https://bogus.com", auth: Auth::AuthBase.new, ssl: {})
        assert_equal("bogus", connection.connection.headers["FaradaySettings"])
      ensure
        FaradaySettings.with_connection { |_| }
      end
    end
  end
end
