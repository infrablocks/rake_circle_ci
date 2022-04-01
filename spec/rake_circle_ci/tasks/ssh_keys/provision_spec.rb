# frozen_string_literal: true

require 'spec_helper'

describe RakeCircleCI::Tasks::SSHKeys::Provision do
  include_context 'rake'

  before do
    stub_output
    stub_circle_ci_client
  end

  def define_task(opts = {}, &block)
    opts = { namespace: :ssh_keys }.merge(opts)

    namespace opts[:namespace] do
      subject.define(opts, &block)
    end
  end

  it 'adds a provision task in the namespace in which it is created' do
    define_task(
      project_slug: 'github/org/repo',
      api_token: 'some-token',
      ssh_keys: [
        {
          private_key: File.read('spec/fixtures/1.private')
        }
      ]
    )

    expect(Rake.application)
      .to(have_task_defined('ssh_keys:provision'))
  end

  it 'gives the provision task a description' do
    define_task(
      project_slug: 'github/org/repo',
      api_token: 'some-token',
      ssh_keys: [
        {
          private_key: File.read('spec/fixtures/1.private')
        }
      ]
    )

    expect(Rake::Task['ssh_keys:provision'].full_comment)
      .to(eq('Provision SSH keys on the github/org/repo project'))
  end

  it 'fails if no project slug is provided' do
    define_task(
      api_token: 'some-token',
      ssh_keys: [
        {
          private_key: File.read('spec/fixtures/1.private')
        }
      ]
    )

    expect do
      Rake::Task['ssh_keys:provision'].invoke
    end.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'fails if no API token is provided' do
    define_task(
      project_slug: 'github/org/repo',
      ssh_keys: [
        {
          private_key: File.read('spec/fixtures/1.private')
        }
      ]
    )

    expect do
      Rake::Task['ssh_keys:provision'].invoke
    end.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'defaults to an empty map for ssh keys' do
    define_task(
      api_token: 'some-token',
      project_slug: 'github/org/repo'
    )

    rake_task = Rake::Task['ssh_keys:provision']
    test_task = rake_task.creator

    expect(test_task.ssh_keys).to(eq({}))
  end

  it 'defaults to a base URL of https://circleci.com/api' do
    define_task(
      project_slug: 'github/org/repo',
      api_token: 'some-token',
      ssh_keys: [
        {
          private_key: File.read('spec/fixtures/1.private')
        }
      ]
    )

    rake_task = Rake::Task['ssh_keys:provision']
    test_task = rake_task.creator

    expect(test_task.base_url)
      .to(eq('https://circleci.com/api'))
  end

  # rubocop:disable RSpec/MultipleExpectations
  it 'uses the CircleCI client to create the SSH keys on the project' do
    project_slug = 'github/org/repo'
    api_token = 'some-token'
    private_key = File.read('spec/fixtures/1.private')
    hostname1 = 'github.com'
    hostname2 = 'gitlab.com'

    client = instance_double(RakeCircleCI::Client)

    allow(RakeCircleCI::Client)
      .to(receive(:new)
            .with(hash_including(
                    project_slug: project_slug,
                    api_token: api_token,
                    base_url: 'https://circleci.com/api'
                  ))
            .and_return(client))

    allow(client).to(receive(:create_ssh_key))

    define_task(
      project_slug: project_slug,
      api_token: api_token,
      ssh_keys: [
        { private_key: private_key, hostname: hostname1 },
        { private_key: private_key, hostname: hostname2 }
      ]
    )

    Rake::Task['ssh_keys:provision'].invoke

    expect(client)
      .to(have_received(:create_ssh_key)
            .with(private_key, hostname: hostname1))
    expect(client)
      .to(have_received(:create_ssh_key)
            .with(private_key, hostname: hostname2))
  end
  # rubocop:enable RSpec/MultipleExpectations

  # rubocop:disable RSpec/MultipleExpectations
  it 'does not pass a hostname for an SSH key when not provided' do
    project_slug = 'github/org/repo'
    api_token = 'some-token'
    private_key1 = File.read('spec/fixtures/1.private')
    private_key2 = File.read('spec/fixtures/2.private')
    hostname1 = 'github.com'

    client = instance_double(RakeCircleCI::Client)

    allow(RakeCircleCI::Client)
      .to(receive(:new)
            .with(hash_including(
                    project_slug: project_slug,
                    api_token: api_token,
                    base_url: 'https://circleci.com/api'
                  ))
            .and_return(client))

    allow(client).to(receive(:create_ssh_key))

    define_task(
      project_slug: project_slug,
      api_token: api_token,
      ssh_keys: [
        { private_key: private_key1, hostname: hostname1 },
        { private_key: private_key2 }
      ]
    )

    Rake::Task['ssh_keys:provision'].invoke

    expect(client)
      .to(have_received(:create_ssh_key)
            .with(private_key1, hostname: hostname1))
    expect(client)
      .to(have_received(:create_ssh_key)
            .with(private_key2))
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
    client = instance_double(RakeCircleCI::Client, create_ssh_key: nil)
    allow(RakeCircleCI::Client)
      .to(receive(:new)
            .and_return(client))
  end
end
