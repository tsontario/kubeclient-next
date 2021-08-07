# frozen_string_literal: true

require_relative "kubeconfig/config"

module KubeclientNext
  module Kubeconfig
    Error = Class.new(Error)

    def self.from_file(file)
      hash = YAML.safe_load(file.read, [Date, Time])
      Config.from_hash(hash)
    end
  end
end
