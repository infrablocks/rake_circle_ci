require 'rake_factory'

require_relative '../tasks'

module RakeCircleCI
  module TaskSets
    class EnvironmentVariables < RakeFactory::TaskSet
      prepend RakeFactory::Namespaceable

      parameter :project_slug, required: true
      parameter :api_token, required: true
      parameter :base_url, default: 'https://circleci.com/api'
      parameter :environment_variables, default: {}

      parameter :destroy_task_name, default: :destroy
      parameter :provision_task_name, default: :provision
      parameter :ensure_task_name, default: :ensure

      task Tasks::EnvironmentVariables::Provision,
          name: RakeFactory::DynamicValue.new { |ts|
            ts.provision_task_name
          }
      task Tasks::EnvironmentVariables::Destroy,
          name: RakeFactory::DynamicValue.new { |ts|
            ts.destroy_task_name
          }
      task Tasks::EnvironmentVariables::Ensure,
          name: RakeFactory::DynamicValue.new { |ts|
            ts.ensure_task_name
          }
    end
  end
end
