require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RuboCop::RakeTask.new do |task|
	task.options = ["-a"]
  task.patterns = ["lib/**/*.rb", "spec/**/*.rb"]
end

RSpec::Core::RakeTask.new(:spec)

task(:default).clear
task default: [:rubocop, :spec]
