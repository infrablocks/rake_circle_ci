# frozen_string_literal: true

require 'rake_circle_ci/version'
require 'rake_circle_ci/client'
require 'rake_circle_ci/tasks'
require 'rake_circle_ci/task_sets'

module RakeCircleCI
  def self.define_environment_variables_tasks(opts = {}, &)
    RakeCircleCI::TaskSets::EnvironmentVariables.define(opts, &)
  end

  def self.define_ssh_keys_tasks(opts = {}, &)
    RakeCircleCI::TaskSets::SSHKeys.define(opts, &)
  end

  def self.define_project_tasks(opts = {}, &)
    RakeCircleCI::TaskSets::Project.define(opts, &)
  end
end
