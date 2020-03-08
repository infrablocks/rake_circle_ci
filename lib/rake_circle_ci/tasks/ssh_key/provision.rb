require 'rake_factory'

require_relative '../../client'

module RakeCircleCI
  module Tasks
    module SSHKey
      class Provision < RakeFactory::Task
        default_name :provision
        default_description RakeFactory::DynamicValue.new { |t|
          "Provision SSH key on the #{t.project_slug} project"
        }

        parameter :project_slug, required: true
        parameter :api_token, required: true
        parameter :base_url, default: 'https://circleci.com/api'
        parameter :private_key, required: true
        parameter :hostname

        action do |t|
          client = Client.new(
              base_url: t.base_url,
              api_token: t.api_token,
              project_slug: t.project_slug)

          print "Provisioning SSH key to the '#{t.project_slug}' project... "
          options = t.hostname && {hostname: t.hostname}
          args = [t.private_key, options].compact
          client.create_ssh_key(*args)
        end
      end
    end
  end
end
