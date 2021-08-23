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
  ENV["PARALLELIZE_ME"] = ENV.fetch("PARALLELIZE_ME", "1")
  ENV["MT_CPU"] = ENV.fetch("MT_CPU", "8")
  task.libs << "test"
  task.libs << "lib"
  task.test_files = FileList["test/integration/**/*_test.rb"]
  task.warning = false
end
