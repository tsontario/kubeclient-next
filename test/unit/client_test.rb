# frozen_string_literal: true

require "test_helper"

module K8y
  class ClientTest < TestCase
    def test_from_config_returns_client_instance
      client = Client.from_config(config_fixture)
      assert_instance_of(Client::Client, client)
    end

    def test_from_in_cluster_config_returns_client_instance
      stub_in_cluster_config
      client = Client.from_in_cluster
      assert_instance_of(Client::Client, client)
    end
  end
end
