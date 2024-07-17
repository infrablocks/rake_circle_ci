# frozen_string_literal: true

require 'rake_factory'

require_relative '../../client'

module RakeCircleCI
  module Tasks
    module SSHKeys
      class Provision < RakeFactory::Task
        default_name :provision
        default_description(RakeFactory::DynamicValue.new do |t|
          "Provision SSH keys on the #{t.project_slug} project"
        end)

        parameter :project_slug, required: true
        parameter :api_token, required: true
        parameter :base_url, default: 'https://circleci.com/api'
        parameter :ssh_keys, default: {}

        action do |t|
          client = Client.new(
            base_url: t.base_url,
            api_token: t.api_token,
            project_slug: t.project_slug
          )

          puts "Provisioning all SSH keys to the '#{t.project_slug}' " \
               'project... '

          t.ssh_keys.each do |ssh_key|
            private_key = ssh_key[:private_key]
            hostname = ssh_key[:hostname]
            fingerprint = SSHKey.new(private_key).sha1_fingerprint

            print "Adding SSH key with fingerprint: '#{fingerprint}'"
            print " for hostname: '#{hostname}'" if hostname
            print '...'
            options = hostname && { hostname: }
            args = [private_key, options].compact
            client.create_ssh_key(*args)
            puts 'Done.'
          end
        end
      end
    end
  end
end
