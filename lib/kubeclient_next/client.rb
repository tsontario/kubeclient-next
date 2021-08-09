# frozen_string_literal: true
require_relative "client/client"

module KubeclientNext
  module Client
    Error = Class.new(Error)

    def self.from_config(config)
      Client.new(config: config)
    end
  end
end
