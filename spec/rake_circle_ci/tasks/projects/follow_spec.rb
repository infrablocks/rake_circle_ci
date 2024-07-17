# frozen_string_literal: true

require 'spec_helper'

describe RakeCircleCI::Tasks::Projects::Follow do
  include_context 'rake'

  before do
    stub_output
    stub_circle_ci_client
  end

  def define_task(opts = {}, &block)
    opts = { namespace: :project }.merge(opts)

    namespace opts[:namespace] do
      subject.define(opts, &block)
    end
  end

  it 'adds a follow task in the namespace in which it is created' do
    define_task(
      project_slug: 'github/org/repo',
      api_token: 'some-token'
    )

    expect(Rake.application)
      .to(have_task_defined('project:follow'))
  end

  it 'gives the follow task a description' do
    define_task(
      project_slug: 'github/org/repo',
      api_token: 'some-token'
    )

    expect(Rake::Task['project:follow'].full_comment)
      .to(eq('Follow the github/org/repo project'))
  end

  it 'fails if no project slug is provided' do
    define_task(
      api_token: 'some-token'
    )

    expect do
      Rake::Task['project:follow'].invoke
    end.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'fails if no API token is provided' do
    define_task(
      project_slug: 'github/org/repo'
    )

    expect do
      Rake::Task['project:follow'].invoke
    end.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'defaults to a base URL of https://circleci.com/api' do
    define_task(
      project_slug: 'github/org/repo',
      api_token: 'some-token'
    )

    rake_task = Rake::Task['project:follow']
    test_task = rake_task.creator

    expect(test_task.base_url)
      .to(eq('https://circleci.com/api'))
  end

  it 'uses the CircleCI client to follow the project' do
    project_slug = 'github/org/repo'
    api_token = 'some-token'

    client = instance_double(RakeCircleCI::Client)

    allow(RakeCircleCI::Client)
      .to(receive(:new)
            .with(hash_including(
                    project_slug:,
                    api_token:,
                    base_url: 'https://circleci.com/api'
                  ))
            .and_return(client))

    allow(client).to(receive(:follow_project))

    define_task(
      project_slug:,
      api_token:
    )

    Rake::Task['project:follow'].invoke

    expect(client).to(have_received(:follow_project))
  end

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
    client = instance_double(RakeCircleCI::Client, follow_project: nil)
    allow(RakeCircleCI::Client)
      .to(receive(:new)
            .and_return(client))
  end
end
