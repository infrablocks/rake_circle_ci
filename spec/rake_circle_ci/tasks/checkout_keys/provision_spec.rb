# frozen_string_literal: true

require 'spec_helper'

describe RakeCircleCI::Tasks::CheckoutKeys::Provision do
  include_context 'rake'

  before do
    stub_output
    stub_circle_ci_client
  end

  def define_task(opts = {}, &block)
    opts = { namespace: :checkout_keys }.merge(opts)

    namespace opts[:namespace] do
      subject.define(opts, &block)
    end
  end

  it 'adds a provision task in the namespace in which it is created' do
    define_task(
      project_slug: 'github/org/repo',
      api_token: 'some-token',
      checkout_keys: [
        {
          type: 'deploy-key'
        }
      ]
    )

    expect(Rake.application)
      .to(have_task_defined('checkout_keys:provision'))
  end

  it 'gives the provision task a description' do
    define_task(
      project_slug: 'github/org/repo',
      api_token: 'some-token',
      checkout_keys: [
        {
          type: 'deploy-key'
        }
      ]
    )

    expect(Rake::Task['checkout_keys:provision'].full_comment)
      .to(eq('Provision checkout keys on the github/org/repo project'))
  end

  it 'fails if no project slug is provided' do
    define_task(
      api_token: 'some-token',
      checkout_keys: [
        {
          type: 'deploy-key'
        }
      ]
    )

    expect do
      Rake::Task['checkout_keys:provision'].invoke
    end.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'fails if no API token is provided' do
    define_task(
      project_slug: 'github/org/repo',
      checkout_keys: [
        {
          type: 'deploy-key'
        }
      ]
    )

    expect do
      Rake::Task['checkout_keys:provision'].invoke
    end.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'defaults to an empty array for checkout keys' do
    define_task(
      api_token: 'some-token',
      project_slug: 'github/org/repo'
    )

    rake_task = Rake::Task['checkout_keys:provision']
    test_task = rake_task.creator

    expect(test_task.checkout_keys).to(eq([]))
  end

  it 'defaults to a base URL of https://circleci.com/api' do
    define_task(
      project_slug: 'github/org/repo',
      api_token: 'some-token',
      checkout_keys: [
        {
          type: 'deploy-key'
        }
      ]
    )

    rake_task = Rake::Task['checkout_keys:provision']
    test_task = rake_task.creator

    expect(test_task.base_url)
      .to(eq('https://circleci.com/api'))
  end

  # rubocop:disable RSpec/MultipleExpectations
  it 'uses the CircleCI client to create the checkout keys on the project' do
    project_slug = 'github/org/repo'
    api_token = 'some-token'

    client = instance_double(RakeCircleCI::Client)

    allow(RakeCircleCI::Client)
      .to(receive(:new)
            .with(hash_including(
                    project_slug: project_slug,
                    api_token: api_token,
                    base_url: 'https://circleci.com/api'
                  ))
            .and_return(client))

    allow(client).to(receive(:create_checkout_key))

    define_task(
      project_slug: project_slug,
      api_token: api_token,
      checkout_keys: [
        { type: :deploy_key },
        { type: :github_user_key }
      ]
    )

    Rake::Task['checkout_keys:provision'].invoke

    expect(client)
      .to(have_received(:create_checkout_key)
            .with(:deploy_key))
    expect(client)
      .to(have_received(:create_checkout_key)
            .with(:github_user_key))
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
    client = instance_double(RakeCircleCI::Client, create_checkout_key: nil)
    allow(RakeCircleCI::Client)
      .to(receive(:new)
            .and_return(client))
  end
end
