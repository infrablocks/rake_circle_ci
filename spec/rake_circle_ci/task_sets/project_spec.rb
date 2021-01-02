require 'spec_helper'
require 'fileutils'

describe RakeCircleCI::TaskSets::Project do
  include_context :rake

  def define_tasks(opts = {}, &block)
    subject.define({
        project_slug: 'github/org/repo',
        api_token: 'some-token'
    }.merge(opts), &block)
  end

  it 'adds all tasks in the provided namespace when supplied' do
    define_tasks(namespace: :circle_ci)

    expect(Rake::Task.task_defined?('circle_ci:project:follow'))
        .to(be(true))
    expect(Rake::Task.task_defined?('circle_ci:env_vars:provision'))
        .to(be(true))
    expect(Rake::Task.task_defined?('circle_ci:env_vars:destroy'))
        .to(be(true))
    expect(Rake::Task.task_defined?('circle_ci:env_vars:ensure'))
        .to(be(true))
    expect(Rake::Task.task_defined?('circle_ci:ssh_keys:provision'))
        .to(be(true))
    expect(Rake::Task.task_defined?('circle_ci:ssh_keys:destroy'))
        .to(be(true))
    expect(Rake::Task.task_defined?('circle_ci:ssh_keys:ensure'))
        .to(be(true))
    expect(Rake::Task.task_defined?('circle_ci:checkout_keys:provision'))
        .to(be(true))
    expect(Rake::Task.task_defined?('circle_ci:checkout_keys:destroy'))
        .to(be(true))
    expect(Rake::Task.task_defined?('circle_ci:checkout_keys:ensure'))
        .to(be(true))
  end

  it 'adds all tasks in the root namespace when none supplied' do
    define_tasks

    expect(Rake::Task.task_defined?('project:follow'))
        .to(be(true))
    expect(Rake::Task.task_defined?('env_vars:provision'))
        .to(be(true))
    expect(Rake::Task.task_defined?('env_vars:destroy'))
        .to(be(true))
    expect(Rake::Task.task_defined?('env_vars:ensure'))
        .to(be(true))
    expect(Rake::Task.task_defined?('ssh_keys:provision'))
        .to(be(true))
    expect(Rake::Task.task_defined?('ssh_keys:destroy'))
        .to(be(true))
    expect(Rake::Task.task_defined?('ssh_keys:ensure'))
        .to(be(true))
    expect(Rake::Task.task_defined?('checkout_keys:provision'))
        .to(be(true))
    expect(Rake::Task.task_defined?('checkout_keys:destroy'))
        .to(be(true))
    expect(Rake::Task.task_defined?('checkout_keys:ensure'))
        .to(be(true))
  end

  context 'project' do
    it 'adds all project tasks in the provided namespace ' +
        'when supplied' do
      define_tasks(project_namespace: :main_project)

      expect(Rake::Task.task_defined?(
          'main_project:follow'))
          .to(be(true))
    end

    it 'adds all environment variable tasks in the project namespace ' +
        'when none supplied' do
      define_tasks

      expect(Rake::Task.task_defined?(
          'project:follow'))
          .to(be(true))
    end

    context 'follow task' do
      it 'configures with the provided project slug and api token' do
        project_slug = 'gitlab/my-org/my-repo'
        api_token = 'some-api-token'

        define_tasks(
            project_slug: project_slug,
            api_token: api_token)

        rake_task = Rake::Task["project:follow"]

        expect(rake_task.creator.project_slug).to(eq(project_slug))
        expect(rake_task.creator.api_token).to(eq(api_token))
      end

      it 'uses a base url of https://circleci.com/api by default' do
        define_tasks

        rake_task = Rake::Task["project:follow"]

        expect(rake_task.creator.base_url)
            .to(eq('https://circleci.com/api'))
      end

      it 'uses the specified base url when provided' do
        base_url = 'https://private.circleci.net/api'

        define_tasks(
            base_url: base_url)

        rake_task = Rake::Task["project:follow"]

        expect(rake_task.creator.base_url).to(eq(base_url))
      end

      it 'uses a name of follow by default' do
        define_tasks

        expect(Rake::Task.task_defined?("project:follow"))
            .to(be(true))
      end

      it 'uses the provided name when supplied' do
        define_tasks(project_follow_task_name: :enable)

        expect(Rake::Task.task_defined?("project:enable"))
            .to(be(true))
      end
    end
  end

  context 'environment_variables' do
    it 'adds all environment variable tasks in the provided namespace ' +
        'when supplied' do
      define_tasks(env_vars_namespace: :environment_variables)

      expect(Rake::Task.task_defined?(
          'environment_variables:provision'))
          .to(be(true))
      expect(Rake::Task.task_defined?(
          'environment_variables:destroy'))
          .to(be(true))
      expect(Rake::Task.task_defined?(
          'environment_variables:ensure'))
          .to(be(true))
    end

    it 'adds all environment variable tasks in the env_vars namespace ' +
        'when none supplied' do
      define_tasks

      expect(Rake::Task.task_defined?(
          'env_vars:provision'))
          .to(be(true))
      expect(Rake::Task.task_defined?(
          'env_vars:destroy'))
          .to(be(true))
      expect(Rake::Task.task_defined?(
          'env_vars:ensure'))
          .to(be(true))
    end

    context 'destroy task' do
      it 'configures with the provided project slug and api token' do
        project_slug = 'gitlab/my-org/my-repo'
        api_token = 'some-api-token'

        define_tasks(
            project_slug: project_slug,
            api_token: api_token)

        rake_task = Rake::Task["env_vars:destroy"]

        expect(rake_task.creator.project_slug).to(eq(project_slug))
        expect(rake_task.creator.api_token).to(eq(api_token))
      end

      it 'uses a base url of https://circleci.com/api by default' do
        define_tasks

        rake_task = Rake::Task["env_vars:destroy"]

        expect(rake_task.creator.base_url)
            .to(eq('https://circleci.com/api'))
      end

      it 'uses the specified base url when provided' do
        base_url = 'https://private.circleci.net/api'

        define_tasks(
            base_url: base_url)

        rake_task = Rake::Task["env_vars:destroy"]

        expect(rake_task.creator.base_url).to(eq(base_url))
      end

      it 'uses a name of destroy by default' do
        define_tasks

        expect(Rake::Task.task_defined?("env_vars:destroy"))
            .to(be(true))
      end

      it 'uses the provided name when supplied' do
        define_tasks(env_vars_destroy_task_name: :destroy_it_all)

        expect(Rake::Task.task_defined?("env_vars:destroy_it_all"))
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

        rake_task = Rake::Task["env_vars:provision"]

        expect(rake_task.creator.project_slug).to(eq(project_slug))
        expect(rake_task.creator.api_token).to(eq(api_token))
      end

      it 'uses a base url of https://circleci.com/api by default' do
        define_tasks

        rake_task = Rake::Task["env_vars:provision"]

        expect(rake_task.creator.base_url).to(eq('https://circleci.com/api'))
      end

      it 'uses the specified base url when provided' do
        base_url = 'https://private.circleci.net/api'

        define_tasks(
            base_url: base_url)

        rake_task = Rake::Task["env_vars:provision"]

        expect(rake_task.creator.base_url).to(eq(base_url))
      end

      it 'uses environment variables of {} by default' do
        define_tasks

        rake_task = Rake::Task["env_vars:provision"]

        expect(rake_task.creator.environment_variables)
            .to(eq({}))
      end

      it 'uses the specified environment variables when provided' do
        environment_variables = {
            THING_THREE: 'value-3'
        }

        define_tasks(
            environment_variables: environment_variables)

        rake_task = Rake::Task["env_vars:provision"]

        expect(rake_task.creator.environment_variables)
            .to(eq(environment_variables))
      end

      it 'uses a name of provision by default' do
        define_tasks

        expect(Rake::Task.task_defined?(
            "env_vars:provision"))
            .to(be(true))
      end

      it 'uses the provided name when supplied' do
        define_tasks(env_vars_provision_task_name: :provision_things)

        expect(Rake::Task.task_defined?("env_vars:provision_things"))
            .to(be(true))
      end
    end

    context 'ensure task' do
      it 'configures with the provided project slug' do
        project_slug = 'gitlab/my-org/my-repo'

        define_tasks(
            project_slug: project_slug)

        rake_task = Rake::Task["env_vars:ensure"]

        expect(rake_task.creator.project_slug).to(eq(project_slug))
      end

      it 'uses a name of ensure by default' do
        define_tasks

        expect(Rake::Task.task_defined?(
            "env_vars:ensure"))
            .to(be(true))
      end

      it 'uses the provided name when supplied' do
        define_tasks(env_vars_ensure_task_name: :make_sure)

        expect(Rake::Task.task_defined?("env_vars:make_sure"))
            .to(be(true))
      end

      it 'uses a destroy task name of destroy by default' do
        define_tasks

        rake_task = Rake::Task["env_vars:ensure"]

        expect(rake_task.creator.destroy_task_name)
            .to(eq(:destroy))
      end

      it 'uses the provided destroy task name when supplied' do
        define_tasks(env_vars_destroy_task_name: :destroy_it_all)

        rake_task = Rake::Task["env_vars:ensure"]

        expect(rake_task.creator.destroy_task_name)
            .to(eq(:destroy_it_all))
      end

      it 'uses a provision task name of provision by default' do
        define_tasks

        rake_task = Rake::Task["env_vars:ensure"]

        expect(rake_task.creator.provision_task_name)
            .to(eq(:provision))
      end

      it 'uses the provided provision task name when supplied' do
        define_tasks(env_vars_provision_task_name: :provision_some_things)

        rake_task = Rake::Task["env_vars:ensure"]

        expect(rake_task.creator.provision_task_name)
            .to(eq(:provision_some_things))
      end
    end
  end

  context "SSH keys" do
    it 'adds all ssh keys tasks in the provided namespace ' +
        'when supplied' do
      define_tasks(ssh_keys_namespace: :keys)

      expect(Rake::Task.task_defined?('keys:provision'))
          .to(be(true))
      expect(Rake::Task.task_defined?('keys:destroy'))
          .to(be(true))
      expect(Rake::Task.task_defined?('keys:ensure'))
          .to(be(true))
    end

    it 'adds all ssh keys tasks in the ssh keys namespace when none supplied' do
      define_tasks

      expect(Rake::Task.task_defined?('ssh_keys:provision'))
          .to(be(true))
      expect(Rake::Task.task_defined?('ssh_keys:destroy'))
          .to(be(true))
      expect(Rake::Task.task_defined?('ssh_keys:ensure'))
          .to(be(true))
    end

    context 'destroy task' do
      it 'configures with the provided project slug and api token' do
        project_slug = 'gitlab/my-org/my-repo'
        api_token = 'some-api-token'

        define_tasks(
            project_slug: project_slug,
            api_token: api_token)

        rake_task = Rake::Task["ssh_keys:destroy"]

        expect(rake_task.creator.project_slug).to(eq(project_slug))
        expect(rake_task.creator.api_token).to(eq(api_token))
      end

      it 'uses a base url of https://circleci.com/api by default' do
        define_tasks

        rake_task = Rake::Task["ssh_keys:destroy"]

        expect(rake_task.creator.base_url).to(eq('https://circleci.com/api'))
      end

      it 'uses the specified base url when provided' do
        base_url = 'https://private.circleci.net/api'

        define_tasks(
            base_url: base_url)

        rake_task = Rake::Task["ssh_keys:destroy"]

        expect(rake_task.creator.base_url).to(eq(base_url))
      end

      it 'uses a name of destroy by default' do
        define_tasks

        expect(Rake::Task.task_defined?("ssh_keys:destroy"))
            .to(be(true))
      end

      it 'uses the provided name when supplied' do
        define_tasks(ssh_keys_destroy_task_name: :destroy_it_all)

        expect(Rake::Task.task_defined?("ssh_keys:destroy_it_all"))
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

        rake_task = Rake::Task["ssh_keys:provision"]

        expect(rake_task.creator.project_slug).to(eq(project_slug))
        expect(rake_task.creator.api_token).to(eq(api_token))
      end

      it 'uses a base url of https://circleci.com/api by default' do
        define_tasks

        rake_task = Rake::Task["ssh_keys:provision"]

        expect(rake_task.creator.base_url).to(eq('https://circleci.com/api'))
      end

      it 'uses the specified base url when provided' do
        base_url = 'https://private.circleci.net/api'

        define_tasks(
            base_url: base_url)

        rake_task = Rake::Task["ssh_keys:provision"]

        expect(rake_task.creator.base_url).to(eq(base_url))
      end

      it 'uses ssh keys of {} by default' do
        define_tasks

        rake_task = Rake::Task["ssh_keys:provision"]

        expect(rake_task.creator.ssh_keys)
            .to(eq({}))
      end

      it 'uses the specified ssh keys when provided' do
        ssh_keys = [
            {
                private_key: File.read('spec/fixtures/1.private'),
                hostname: 'github.com'
            },
            {
                private_key: File.read('spec/fixtures/2.private')
            }
        ]

        define_tasks(
            ssh_keys: ssh_keys)

        rake_task = Rake::Task["ssh_keys:provision"]

        expect(rake_task.creator.ssh_keys)
            .to(eq(ssh_keys))
      end

      it 'uses a name of provision by default' do
        define_tasks

        expect(Rake::Task.task_defined?("ssh_keys:provision"))
            .to(be(true))
      end

      it 'uses the provided name when supplied' do
        define_tasks(ssh_keys_provision_task_name: :provision_things)

        expect(Rake::Task.task_defined?("ssh_keys:provision_things"))
            .to(be(true))
      end
    end

    context 'ensure task' do
      it 'configures with the provided project slug' do
        project_slug = 'gitlab/my-org/my-repo'

        define_tasks(
            project_slug: project_slug)

        rake_task = Rake::Task["ssh_keys:ensure"]

        expect(rake_task.creator.project_slug).to(eq(project_slug))
      end

      it 'uses a name of ensure by default' do
        define_tasks

        expect(Rake::Task.task_defined?("ssh_keys:ensure"))
            .to(be(true))
      end

      it 'uses the provided name when supplied' do
        define_tasks(ssh_keys_ensure_task_name: :make_sure)

        expect(Rake::Task.task_defined?("ssh_keys:make_sure"))
            .to(be(true))
      end

      it 'uses a destroy task name of destroy by default' do
        define_tasks

        rake_task = Rake::Task["ssh_keys:ensure"]

        expect(rake_task.creator.destroy_task_name)
            .to(eq(:destroy))
      end

      it 'uses the provided destroy task name when supplied' do
        define_tasks(ssh_keys_destroy_task_name: :destroy_it_all)

        rake_task = Rake::Task["ssh_keys:ensure"]

        expect(rake_task.creator.destroy_task_name)
            .to(eq(:destroy_it_all))
      end

      it 'uses a provision task name of provision by default' do
        define_tasks

        rake_task = Rake::Task["ssh_keys:ensure"]

        expect(rake_task.creator.provision_task_name)
            .to(eq(:provision))
      end

      it 'uses the provided provision task name when supplied' do
        define_tasks(ssh_keys_provision_task_name: :provision_some_things)

        rake_task = Rake::Task["ssh_keys:ensure"]

        expect(rake_task.creator.provision_task_name)
            .to(eq(:provision_some_things))
      end
    end
  end

  context "checkout keys" do
    it 'adds all checkout keys tasks in the provided namespace ' +
        'when supplied' do
      define_tasks(checkout_keys_namespace: :keys)

      expect(Rake::Task.task_defined?('keys:provision'))
          .to(be(true))
      expect(Rake::Task.task_defined?('keys:destroy'))
          .to(be(true))
      expect(Rake::Task.task_defined?('keys:ensure'))
          .to(be(true))
    end

    it 'adds all checkout keys tasks in the checkout keys namespace when ' +
        'none supplied' do
      define_tasks

      expect(Rake::Task.task_defined?('checkout_keys:provision'))
          .to(be(true))
      expect(Rake::Task.task_defined?('checkout_keys:destroy'))
          .to(be(true))
      expect(Rake::Task.task_defined?('checkout_keys:ensure'))
          .to(be(true))
    end

    context 'destroy task' do
      it 'configures with the provided project slug and api token' do
        project_slug = 'gitlab/my-org/my-repo'
        api_token = 'some-api-token'

        define_tasks(
            project_slug: project_slug,
            api_token: api_token)

        rake_task = Rake::Task["checkout_keys:destroy"]

        expect(rake_task.creator.project_slug).to(eq(project_slug))
        expect(rake_task.creator.api_token).to(eq(api_token))
      end

      it 'uses a base url of https://circleci.com/api by default' do
        define_tasks

        rake_task = Rake::Task["checkout_keys:destroy"]

        expect(rake_task.creator.base_url).to(eq('https://circleci.com/api'))
      end

      it 'uses the specified base url when provided' do
        base_url = 'https://private.circleci.net/api'

        define_tasks(
            base_url: base_url)

        rake_task = Rake::Task["checkout_keys:destroy"]

        expect(rake_task.creator.base_url).to(eq(base_url))
      end

      it 'uses a name of destroy by default' do
        define_tasks

        expect(Rake::Task.task_defined?("checkout_keys:destroy"))
            .to(be(true))
      end

      it 'uses the provided name when supplied' do
        define_tasks(checkout_keys_destroy_task_name: :destroy_it_all)

        expect(Rake::Task.task_defined?("checkout_keys:destroy_it_all"))
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

        rake_task = Rake::Task["checkout_keys:provision"]

        expect(rake_task.creator.project_slug).to(eq(project_slug))
        expect(rake_task.creator.api_token).to(eq(api_token))
      end

      it 'uses a base url of https://circleci.com/api by default' do
        define_tasks

        rake_task = Rake::Task["checkout_keys:provision"]

        expect(rake_task.creator.base_url).to(eq('https://circleci.com/api'))
      end

      it 'uses the specified base url when provided' do
        base_url = 'https://private.circleci.net/api'

        define_tasks(
            base_url: base_url)

        rake_task = Rake::Task["checkout_keys:provision"]

        expect(rake_task.creator.base_url).to(eq(base_url))
      end

      it 'uses checkout keys of [] by default' do
        define_tasks

        rake_task = Rake::Task["checkout_keys:provision"]

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

        rake_task = Rake::Task["checkout_keys:provision"]

        expect(rake_task.creator.checkout_keys)
            .to(eq(checkout_keys))
      end

      it 'uses a name of provision by default' do
        define_tasks

        expect(Rake::Task.task_defined?("checkout_keys:provision"))
            .to(be(true))
      end

      it 'uses the provided name when supplied' do
        define_tasks(checkout_keys_provision_task_name: :provision_things)

        expect(Rake::Task.task_defined?("checkout_keys:provision_things"))
            .to(be(true))
      end
    end

    context 'ensure task' do
      it 'configures with the provided project slug' do
        project_slug = 'gitlab/my-org/my-repo'

        define_tasks(
            project_slug: project_slug)

        rake_task = Rake::Task["checkout_keys:ensure"]

        expect(rake_task.creator.project_slug).to(eq(project_slug))
      end

      it 'uses a name of ensure by default' do
        define_tasks

        expect(Rake::Task.task_defined?("checkout_keys:ensure"))
            .to(be(true))
      end

      it 'uses the provided name when supplied' do
        define_tasks(checkout_keys_ensure_task_name: :make_sure)

        expect(Rake::Task.task_defined?("checkout_keys:make_sure"))
            .to(be(true))
      end

      it 'uses a destroy task name of destroy by default' do
        define_tasks

        rake_task = Rake::Task["checkout_keys:ensure"]

        expect(rake_task.creator.destroy_task_name)
            .to(eq(:destroy))
      end

      it 'uses the provided destroy task name when supplied' do
        define_tasks(checkout_keys_destroy_task_name: :destroy_it_all)

        rake_task = Rake::Task["checkout_keys:ensure"]

        expect(rake_task.creator.destroy_task_name)
            .to(eq(:destroy_it_all))
      end

      it 'uses a provision task name of provision by default' do
        define_tasks

        rake_task = Rake::Task["checkout_keys:ensure"]

        expect(rake_task.creator.provision_task_name)
            .to(eq(:provision))
      end

      it 'uses the provided provision task name when supplied' do
        define_tasks(checkout_keys_provision_task_name: :provision_some_things)

        rake_task = Rake::Task["checkout_keys:ensure"]

        expect(rake_task.creator.provision_task_name)
            .to(eq(:provision_some_things))
      end
    end
  end
end
