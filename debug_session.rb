#!/usr/bin/env ruby
# frozen_string_literal: true
require("byebug")
require_relative("lib/k8y")

CONFIG = K8y::Kubeconfig.from_file(File.open(File.join(Dir.home, ".kube", "config")))
CLIENT = K8y::Client.from_config(CONFIG)
