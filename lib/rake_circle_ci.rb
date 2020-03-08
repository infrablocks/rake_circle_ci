require 'rake_circle_ci/version'
require 'rake_circle_ci/client'
require 'rake_circle_ci/tasks'
require 'rake_circle_ci/task_sets'

module RakeCircleCI
  def self.define_environment_variables_tasks(opts = {}, &block)
    RakeCircleCI::TaskSets::EnvironmentVariables.define(opts, &block)
  end
end