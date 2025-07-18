require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :standardrb do
  sh "bundle exec standardrb --fix"
end

task(:default).clear
task default: %i[standardrb spec]
