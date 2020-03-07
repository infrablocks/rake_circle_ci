require 'rake_factory'

require_relative '../../client'

module RakeCircleCI
  module Tasks
    module EnvironmentVariables
      class Provision < RakeFactory::Task
        default_name :provision
        default_description RakeFactory::DynamicValue.new { |t|
          "Provision environment variables on the #{t.project_slug} project"
        }

        parameter :project_slug, required: true
        parameter :api_token, required: true
        parameter :base_url, default: 'https://circleci.com/api'
        parameter :environment_variables, default: {}

        action do |t|
          client = Client.new(
              base_url: t.base_url,
              api_token: t.api_token,
              project_slug: t.project_slug)

          puts "Provisioning all environment variables to the " +
              "'#{t.project_slug}' project... "

          t.environment_variables.each do |name, value|
            print "Setting environment variable: '#{name}'... "
            client.create_env_var(name.to_s, value)
            puts "Done."
          end
        end
      end
    end
  end
end
