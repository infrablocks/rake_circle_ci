require 'spec_helper'

describe RakeCircleCI::Tasks::EnvironmentVariables::Provision do
  include_context :rake

  def define_task(opts = {}, &block)
    opts = {namespace: :env_vars}.merge(opts)

    namespace opts[:namespace] do
      subject.define(opts, &block)
    end
  end

  it 'adds a provision task in the namespace in which it is created' do
    define_task(
        project_slug: 'github/org/repo',
        api_token: 'some-token')

    expect(Rake::Task.task_defined?('env_vars:provision'))
        .to(be(true))
  end

  it 'gives the provision task a description' do
    define_task(
        project_slug: 'github/org/repo',
        api_token: 'some-token')

    expect(Rake::Task['env_vars:provision'].full_comment)
        .to(eq('Provision environment variables on the ' +
            'github/org/repo project'))
  end

  it 'fails if no project slug is provided' do
    define_task(
        api_token: 'some-token')

    expect {
      Rake::Task['env_vars:provision'].invoke
    }.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'fails if no API token is provided' do
    define_task(
        project_slug: 'github/org/repo')

    expect {
      Rake::Task['env_vars:provision'].invoke
    }.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'defaults to an empty map for environment variables' do
    define_task(
        project_slug: 'github/org/repo',
        api_token: 'some-token')

    rake_task = Rake::Task['env_vars:provision']
    test_task = rake_task.creator

    expect(test_task.environment_variables).to(eq({}))
  end

  it 'defaults to a base URL of https://circleci.com/api' do
    define_task(
        project_slug: 'github/org/repo',
        api_token: 'some-token')

    rake_task = Rake::Task['env_vars:provision']
    test_task = rake_task.creator

    expect(test_task.base_url)
        .to(eq('https://circleci.com/api'))
  end

  it 'uses the CircleCI client to create each environment variable ' +
      'on the project' do
    project_slug = 'github/org/repo'
    api_token = 'some-token'
    environment_variables = {
        'THING_ONE': 'value-1',
        'THING_TWO': 'value-2'
    }

    client = double('CircleCI client')

    allow(RakeCircleCI::Client)
        .to(receive(:new)
            .with(hash_including(
                project_slug: project_slug,
                api_token: api_token,
                base_url: 'https://circleci.com/api'))
            .and_return(client))

    expect(client).to(receive(:create_env_var)
        .with('THING_ONE', 'value-1'))
    expect(client).to(receive(:create_env_var)
        .with('THING_TWO', 'value-2'))

    define_task(
        project_slug: project_slug,
        api_token: api_token,
        environment_variables: environment_variables)

    Rake::Task['env_vars:provision'].invoke
  end
end
