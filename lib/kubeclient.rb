# frozen_string_literal: true

require_relative "kubeclient/version"
require_relative "kubeclient/kubeconfig"

module Kubeclient
  class Error < StandardError; end
end
