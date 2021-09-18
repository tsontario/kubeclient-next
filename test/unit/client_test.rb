# frozen_string_literal: true

require "test_helper"

module K8y
  class ClientTest < TestCase
    def test_from_config
      client = Client.from_config(config_fixture)
      assert_instance_of(Client::Client, client)
    end
  end
end
