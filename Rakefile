# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

task default: ["test"]

desc("Run test suite")
Rake::TestTask.new(:test) do |task|
  task.libs << "test"
  task.libs << "lib"
  task.test_files = FileList["test/unit/**/*_test.rb"]
end

desc("Run in-cluster integrations tests")
Rake::TestTask.new(:test_integration) do |task|
  task.libs << "test"
  task.libs << "lib"
  task.test_files = FileList["test/integration/**/*_test.rb"]
end

task :scratch do |_task|
  require "byebug"
  require_relative "lib/kubeclient_next"
  KUBECONFIG = File.open(File.join(Dir.home, ".kube", "config"))
  config = KubeclientNext::Kubeconfig.from_file(KUBECONFIG)
  client = KubeclientNext::Client.from_config(config)
  client.discover!
  byebug
  deploy = client.get_deployment(namespace: "kube-system", name: "nginx").body
  # patch = [
  #   { 'op' => 'add', 'path' => '/metadata/labels/foo', 'value' => 'BANG' }
  # ]
  # result = client.patch_deployment(namespace: "default", name: "nginx", strategy: :json, data: patch)
  # result = client.patch_deployment(namespace: "default", name: "nginx", strategy: :strategic_merge, data: {metadata: {labels: {baz: "bar"}}})
  # result = client.patch_deployment(namespace: "default", name: "nginx", strategy: :merge, data: {metadata: {labels: {baz: "barTT"}}})
  client.patch_deployment(namespace: "default", name: "nginx", data: {}, strategy: :json)
end
