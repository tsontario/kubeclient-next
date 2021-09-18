# frozen_string_literal: true

require_relative "kubeconfig/config"

module K8y
  module Kubeconfig
    Error = Class.new(Error)

    KUBECONFIG = ENV["KUBECONFIG"]

    def self.from_file(file = File.open(KUBECONFIG))
      hash = YAML.safe_load(file.read, permitted_classes: [Date, Time])
      Config.from_hash(hash)
    end
  end
end
