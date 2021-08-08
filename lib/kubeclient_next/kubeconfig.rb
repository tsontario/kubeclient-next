# frozen_string_literal: true

require_relative "kubeconfig/config"

module KubeclientNext
  module Kubeconfig
    KUBECONFIG = ENV["KUBECONFIG"]
    Error = Class.new(Error)

    def self.from_file(file = File.open(KUBECONFIG))
      hash = YAML.safe_load(file.read, [Date, Time])
      Config.from_hash(hash)
    end
  end
end
