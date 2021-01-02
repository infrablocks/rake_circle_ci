require 'rake_factory'

require_relative '../../client'

module RakeCircleCI
  module Tasks
    module CheckoutKeys
      class Provision < RakeFactory::Task
        default_name :provision
        default_description RakeFactory::DynamicValue.new { |t|
          "Provision checkout keys on the #{t.project_slug} project"
        }

        parameter :project_slug, required: true
        parameter :api_token, required: true
        parameter :base_url, default: 'https://circleci.com/api'
        parameter :checkout_keys, default: []

        action do |t|
          client = Client.new(
              base_url: t.base_url,
              api_token: t.api_token,
              project_slug: t.project_slug)

          puts "Provisioning all checkout keys to the '#{t.project_slug}' " +
              "project... "

          t.checkout_keys.each do |checkout_key|
            type = checkout_key[:type]

            print "Adding checkout key of type: '#{type}'..."
            client.create_checkout_key(type)
            puts "Done."
          end
        end
      end
    end
  end
end
