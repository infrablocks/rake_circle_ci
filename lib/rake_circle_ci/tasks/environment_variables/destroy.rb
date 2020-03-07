require 'rake_factory'

require_relative '../../client'

module RakeCircleCI
  module Tasks
    module EnvironmentVariables
      class Destroy < RakeFactory::Task
        default_name :destroy
        default_description RakeFactory::DynamicValue.new { |t|
          "Destroy environment variables on the #{t.project_slug} project"
        }

        parameter :project_slug, required: true
        parameter :api_token, required: true
        parameter :base_url, default: 'https://circleci.com/api'

        action do |t|
          client = Client.new(
              base_url: t.base_url,
              api_token: t.api_token,
              project_slug: t.project_slug)

          print "Destroying all environment variables on the " +
              "'#{t.project_slug}' project... "
          client.delete_env_vars
          puts "Done."
        end
      end
    end
  end
end
