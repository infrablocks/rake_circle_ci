require 'spec_helper'
require 'fileutils'

describe RakeCircleCI::TaskSets::CheckoutKeys do
  include_context :rake

  def define_tasks(opts = {}, &block)
    subject.define({
        project_slug: 'github/org/repo',
        api_token: 'some-token'
    }.merge(opts), &block)
  end

  it 'adds all checkout keys tasks in the provided namespace ' +
      'when supplied' do
    define_tasks(namespace: :checkout_keys)

    expect(Rake::Task.task_defined?('checkout_keys:provision'))
        .to(be(true))
    expect(Rake::Task.task_defined?('checkout_keys:destroy'))
        .to(be(true))
    expect(Rake::Task.task_defined?('checkout_keys:ensure'))
        .to(be(true))
  end

  it 'adds all checkout keys tasks in the root namespace when none supplied' do
    define_tasks

    expect(Rake::Task.task_defined?('provision')).to(be(true))
    expect(Rake::Task.task_defined?('destroy')).to(be(true))
    expect(Rake::Task.task_defined?('ensure')).to(be(true))
  end

  context 'destroy task' do
    it 'configures with the provided project slug and api token' do
      project_slug = 'gitlab/my-org/my-repo'
      api_token = 'some-api-token'

      define_tasks(
          project_slug: project_slug,
          api_token: api_token)

      rake_task = Rake::Task["destroy"]

      expect(rake_task.creator.project_slug).to(eq(project_slug))
      expect(rake_task.creator.api_token).to(eq(api_token))
    end

    it 'uses a base url of https://circleci.com/api by default' do
      define_tasks

      rake_task = Rake::Task["destroy"]

      expect(rake_task.creator.base_url).to(eq('https://circleci.com/api'))
    end

    it 'uses the specified base url when provided' do
      base_url = 'https://private.circleci.net/api'

      define_tasks(
          base_url: base_url)

      rake_task = Rake::Task["destroy"]

      expect(rake_task.creator.base_url).to(eq(base_url))
    end

    it 'uses a name of destroy by default' do
      define_tasks

      expect(Rake::Task.task_defined?("destroy")).to(be(true))
    end

    it 'uses the provided name when supplied' do
      define_tasks(destroy_task_name: :destroy_it_all)

      expect(Rake::Task.task_defined?("destroy_it_all"))
          .to(be(true))
    end
  end

  context 'provision task' do
    it 'configures with the provided project slug and api token' do
      project_slug = 'gitlab/my-org/my-repo'
      api_token = 'some-api-token'

      define_tasks(
          project_slug: project_slug,
          api_token: api_token)

      rake_task = Rake::Task["provision"]

      expect(rake_task.creator.project_slug).to(eq(project_slug))
      expect(rake_task.creator.api_token).to(eq(api_token))
    end

    it 'uses a base url of https://circleci.com/api by default' do
      define_tasks

      rake_task = Rake::Task["provision"]

      expect(rake_task.creator.base_url).to(eq('https://circleci.com/api'))
    end

    it 'uses the specified base url when provided' do
      base_url = 'https://private.circleci.net/api'

      define_tasks(
          base_url: base_url)

      rake_task = Rake::Task["provision"]

      expect(rake_task.creator.base_url).to(eq(base_url))
    end

    it 'uses checkout keys of [] by default' do
      define_tasks

      rake_task = Rake::Task["provision"]

      expect(rake_task.creator.checkout_keys)
          .to(eq([]))
    end

    it 'uses the specified checkout keys when provided' do
      checkout_keys = [
          {
              type: :deploy_key
          },
          {
              type: :github_user_key
          }
      ]

      define_tasks(
          checkout_keys: checkout_keys)

      rake_task = Rake::Task["provision"]

      expect(rake_task.creator.checkout_keys)
          .to(eq(checkout_keys))
    end

    it 'uses a name of provision by default' do
      define_tasks

      expect(Rake::Task.task_defined?("provision")).to(be(true))
    end

    it 'uses the provided name when supplied' do
      define_tasks(provision_task_name: :provision_things)

      expect(Rake::Task.task_defined?("provision_things"))
          .to(be(true))
    end
  end

  context 'ensure task' do
    it 'configures with the provided project slug' do
      project_slug = 'gitlab/my-org/my-repo'

      define_tasks(
          project_slug: project_slug)

      rake_task = Rake::Task["ensure"]

      expect(rake_task.creator.project_slug).to(eq(project_slug))
    end

    it 'uses a name of ensure by default' do
      define_tasks

      expect(Rake::Task.task_defined?("ensure")).to(be(true))
    end

    it 'uses the provided name when supplied' do
      define_tasks(ensure_task_name: :make_sure)

      expect(Rake::Task.task_defined?("make_sure"))
          .to(be(true))
    end

    it 'uses a destroy task name of destroy by default' do
      define_tasks

      rake_task = Rake::Task["ensure"]

      expect(rake_task.creator.destroy_task_name)
          .to(eq(:destroy))
    end

    it 'uses the provided destroy task name when supplied' do
      define_tasks(destroy_task_name: :destroy_it_all)

      rake_task = Rake::Task["ensure"]

      expect(rake_task.creator.destroy_task_name)
          .to(eq(:destroy_it_all))
    end

    it 'uses a provision task name of provision by default' do
      define_tasks

      rake_task = Rake::Task["ensure"]

      expect(rake_task.creator.provision_task_name)
          .to(eq(:provision))
    end

    it 'uses the provided provision task name when supplied' do
      define_tasks(provision_task_name: :provision_some_things)

      rake_task = Rake::Task["ensure"]

      expect(rake_task.creator.provision_task_name)
          .to(eq(:provision_some_things))
    end
  end
end
