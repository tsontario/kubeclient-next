# frozen_string_literal: true
require_relative "clients/client"

module KubeclientNext
  module Clients
    Error = Class.new(Error)

    def self.from_config(config)
      Client.new(config: config)
    end
  end
end
