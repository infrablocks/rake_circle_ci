require 'rake_factory'

require_relative '../../client'

module RakeCircleCI
  module Tasks
    module SSHKeys
      class Destroy < RakeFactory::Task
        default_name :destroy
        default_description RakeFactory::DynamicValue.new { |t|
          "Destroy SSH keys in the #{t.project_slug} project"
        }

        parameter :project_slug, required: true
        parameter :api_token, required: true
        parameter :base_url, default: 'https://circleci.com/api'
        parameter :ssh_keys, default: {}

        action do |t|
          client = Client.new(
              base_url: t.base_url,
              api_token: t.api_token,
              project_slug: t.project_slug)

          print "Destroying all SSH keys in the '#{t.project_slug}' " +
              "project... "
          client.delete_ssh_keys
          puts "Done."
        end
      end
    end
  end
end
