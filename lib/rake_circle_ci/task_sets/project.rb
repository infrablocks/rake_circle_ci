# frozen_string_literal: true

require 'rake_factory'

require_relative '../tasks'

module RakeCircleCI
  module TaskSets
    class Project < RakeFactory::TaskSet
      prepend RakeFactory::Namespaceable

      parameter :project_slug, required: true
      parameter :api_token, required: true
      parameter :base_url, default: 'https://circleci.com/api'
      parameter :environment_variables, default: {}
      parameter :ssh_keys, default: {}
      parameter :checkout_keys, default: []

      parameter :env_vars_namespace, default: :env_vars
      parameter :env_vars_destroy_task_name, default: :destroy
      parameter :env_vars_provision_task_name, default: :provision
      parameter :env_vars_ensure_task_name, default: :ensure

      parameter :ssh_keys_namespace, default: :ssh_keys
      parameter :ssh_keys_destroy_task_name, default: :destroy
      parameter :ssh_keys_provision_task_name, default: :provision
      parameter :ssh_keys_ensure_task_name, default: :ensure

      parameter :checkout_keys_namespace, default: :checkout_keys
      parameter :checkout_keys_destroy_task_name, default: :destroy
      parameter :checkout_keys_provision_task_name, default: :provision
      parameter :checkout_keys_ensure_task_name, default: :ensure

      parameter :project_namespace, default: :project
      parameter :project_follow_task_name, default: :follow

      task Tasks::EnvironmentVariables::Provision,
           name: RakeFactory::DynamicValue.new { |ts|
             ts.env_vars_provision_task_name
           }
      task Tasks::EnvironmentVariables::Destroy,
           name: RakeFactory::DynamicValue.new { |ts|
             ts.env_vars_destroy_task_name
           }
      task Tasks::EnvironmentVariables::Ensure,
           name: RakeFactory::DynamicValue.new { |ts|
             ts.env_vars_ensure_task_name
           },
           destroy_task_name: RakeFactory::DynamicValue.new { |ts|
             ts.env_vars_destroy_task_name
           },
           provision_task_name: RakeFactory::DynamicValue.new { |ts|
             ts.env_vars_provision_task_name
           }
      task Tasks::SSHKeys::Provision,
           name: RakeFactory::DynamicValue.new { |ts|
             ts.ssh_keys_provision_task_name
           }
      task Tasks::SSHKeys::Destroy,
           name: RakeFactory::DynamicValue.new { |ts|
             ts.ssh_keys_destroy_task_name
           }
      task Tasks::SSHKeys::Ensure,
           name: RakeFactory::DynamicValue.new { |ts|
             ts.ssh_keys_ensure_task_name
           },
           destroy_task_name: RakeFactory::DynamicValue.new { |ts|
             ts.ssh_keys_destroy_task_name
           },
           provision_task_name: RakeFactory::DynamicValue.new { |ts|
             ts.ssh_keys_provision_task_name
           }
      task Tasks::CheckoutKeys::Provision,
           name: RakeFactory::DynamicValue.new { |ts|
             ts.checkout_keys_provision_task_name
           }
      task Tasks::CheckoutKeys::Destroy,
           name: RakeFactory::DynamicValue.new { |ts|
             ts.checkout_keys_destroy_task_name
           }
      task Tasks::CheckoutKeys::Ensure,
           name: RakeFactory::DynamicValue.new { |ts|
             ts.checkout_keys_ensure_task_name
           },
           destroy_task_name: RakeFactory::DynamicValue.new { |ts|
             ts.checkout_keys_destroy_task_name
           },
           provision_task_name: RakeFactory::DynamicValue.new { |ts|
             ts.checkout_keys_provision_task_name
           }
      task Tasks::Projects::Follow,
           name: RakeFactory::DynamicValue.new { |ts|
             ts.project_follow_task_name
           }

      def define_on(application)
        around_define(application) do
          self.class.tasks.each do |task_definition|
            application.in_namespace(resolve_namespace(task_definition)) do
              task_definition.for_task_set(self).define_on(application)
            end
          end
        end
      end

      private

      def resolve_namespace(task_definition)
        case task_definition.klass.to_s
        when /EnvironmentVariables/ then env_vars_namespace
        when /SSHKeys/              then ssh_keys_namespace
        when /CheckoutKeys/         then checkout_keys_namespace
        else
          project_namespace
        end
      end
    end
  end
end
