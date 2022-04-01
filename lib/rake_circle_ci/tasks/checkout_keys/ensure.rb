# frozen_string_literal: true

require 'rake_factory'

module RakeCircleCI
  module Tasks
    module CheckoutKeys
      class Ensure < RakeFactory::Task
        default_name :ensure
        default_description(RakeFactory::DynamicValue.new do |t|
          'Ensure checkout keys are configured on the ' \
            "#{t.project_slug} project"
        end)

        parameter :project_slug, required: true

        parameter :provision_task_name, default: :provision
        parameter :destroy_task_name, default: :destroy

        action do |t, args|
          t.application[t.destroy_task_name, t.scope].invoke(*args)
          t.application[t.provision_task_name, t.scope].invoke(*args)
        end
      end
    end
  end
end
