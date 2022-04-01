# frozen_string_literal: true

require 'rake_factory'

require_relative '../../client'

module RakeCircleCI
  module Tasks
    module Projects
      class Follow < RakeFactory::Task
        default_name :follow
        default_description(RakeFactory::DynamicValue.new do |t|
          "Follow the #{t.project_slug} project"
        end)

        parameter :project_slug, required: true
        parameter :api_token, required: true
        parameter :base_url, default: 'https://circleci.com/api'

        action do |t|
          client = Client.new(
            base_url: t.base_url,
            api_token: t.api_token,
            project_slug: t.project_slug
          )

          print "Following the '#{t.project_slug}' project... "
          client.follow_project
          puts 'Done.'
        end
      end
    end
  end
end
