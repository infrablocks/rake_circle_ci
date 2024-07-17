# frozen_string_literal: true

require 'spec_helper'

describe RakeCircleCI::Tasks::EnvironmentVariables::Provision do
  include_context 'rake'

  before do
    stub_output
    stub_circle_ci_client
  end

  def define_task(opts = {}, &block)
    opts = { namespace: :env_vars }.merge(opts)

    namespace opts[:namespace] do
      subject.define(opts, &block)
    end
  end

  it 'adds a provision task in the namespace in which it is created' do
    define_task(
      project_slug: 'github/org/repo',
      api_token: 'some-token'
    )

    expect(Rake.application)
      .to(have_task_defined('env_vars:provision'))
  end

  it 'gives the provision task a description' do
    define_task(
      project_slug: 'github/org/repo',
      api_token: 'some-token'
    )

    expect(Rake::Task['env_vars:provision'].full_comment)
      .to(eq('Provision environment variables on the ' \
             'github/org/repo project'))
  end

  it 'fails if no project slug is provided' do
    define_task(
      api_token: 'some-token'
    )

    expect do
      Rake::Task['env_vars:provision'].invoke
    end.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'fails if no API token is provided' do
    define_task(
      project_slug: 'github/org/repo'
    )

    expect do
      Rake::Task['env_vars:provision'].invoke
    end.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'defaults to an empty map for environment variables' do
    define_task(
      project_slug: 'github/org/repo',
      api_token: 'some-token'
    )

    rake_task = Rake::Task['env_vars:provision']
    test_task = rake_task.creator

    expect(test_task.environment_variables).to(eq({}))
  end

  it 'defaults to a base URL of https://circleci.com/api' do
    define_task(
      project_slug: 'github/org/repo',
      api_token: 'some-token'
    )

    rake_task = Rake::Task['env_vars:provision']
    test_task = rake_task.creator

    expect(test_task.base_url)
      .to(eq('https://circleci.com/api'))
  end

  # rubocop:disable RSpec/MultipleExpectations
  it 'uses the CircleCI client to create each environment variable ' \
     'on the project' do
    project_slug = 'github/org/repo'
    api_token = 'some-token'
    environment_variables = {
      THING_ONE: 'value-1',
      THING_TWO: 'value-2'
    }

    client = instance_double(RakeCircleCI::Client)

    allow(RakeCircleCI::Client)
      .to(receive(:new)
            .with(hash_including(
                    project_slug:,
                    api_token:,
                    base_url: 'https://circleci.com/api'
                  ))
            .and_return(client))

    allow(client).to(receive(:create_env_var))

    define_task(
      project_slug:,
      api_token:,
      environment_variables:
    )

    Rake::Task['env_vars:provision'].invoke

    expect(client)
      .to(have_received(:create_env_var)
            .with('THING_ONE', 'value-1'))
    expect(client)
      .to(have_received(:create_env_var)
            .with('THING_TWO', 'value-2'))
  end
  # rubocop:enable RSpec/MultipleExpectations

  def stub_output
    # rubocop:disable RSpec/AnyInstance
    %i[print puts].each do |method|
      allow_any_instance_of(Kernel).to(receive(method))
      allow($stdout).to(receive(method))
      allow($stderr).to(receive(method))
    end
    # rubocop:enable RSpec/AnyInstance
  end

  def stub_circle_ci_client
    client = instance_double(RakeCircleCI::Client, create_env_var: nil)
    allow(RakeCircleCI::Client)
      .to(receive(:new)
            .and_return(client))
  end
end
