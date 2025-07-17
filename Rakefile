require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RuboCop::RakeTask.new do |task|
  task.options = %w[-a]
end

RSpec::Core::RakeTask.new(:spec)

task(:default).clear
task default: %i[rubocop spec]
