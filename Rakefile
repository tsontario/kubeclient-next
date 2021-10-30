# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

task default: ["test"]

desc("Run unit/integration test suite")
Rake::TestTask.new(:test) do |task|
  task.libs << "test"
  task.libs << "lib"
  task.test_files = FileList[
    "test/unit/**/*_test.rb",
    "test/integration/**/*_test.rb",
  ]
end

desc("Run unit test suite")
Rake::TestTask.new(:test_unit) do |task|
  task.libs << "test"
  task.libs << "lib"
  task.test_files = FileList["test/unit/**/*_test.rb"]
end

desc("Run integration test suite")
Rake::TestTask.new(:test_integration) do |task|
  task.libs << "test"
  task.libs << "lib"
  task.test_files = FileList["test/integration/**/*_test.rb"]
end

desc("Run in-cluster integrations tests")
Rake::TestTask.new(:test_cluster) do |task|
  ENV["PARALLELIZE_ME"] = ENV.fetch("PARALLELIZE_ME", "1")
  ENV["MT_CPU"] = ENV.fetch("MT_CPU", "8")
  task.libs << "test"
  task.libs << "lib"
  task.test_files = FileList["test/cluster_integration/**/*_test.rb"]
  task.warning = false
end
