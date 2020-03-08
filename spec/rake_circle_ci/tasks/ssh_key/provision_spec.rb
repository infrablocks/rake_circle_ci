require 'spec_helper'

describe RakeCircleCI::Tasks::SSHKey::Provision do
  include_context :rake

  before(:each) do
    stub_output
    stub_circle_ci_client
  end

  def define_task(opts = {}, &block)
    opts = {namespace: :ssh_key}.merge(opts)

    namespace opts[:namespace] do
      subject.define(opts, &block)
    end
  end

  it 'adds a provision task in the namespace in which it is created' do
    define_task(
        project_slug: 'github/org/repo',
        api_token: 'some-token',
        private_key: File.read('spec/fixtures/ssh.private'))

    expect(Rake::Task.task_defined?('ssh_key:provision'))
        .to(be(true))
  end

  it 'gives the provision task a description' do
    define_task(
        project_slug: 'github/org/repo',
        api_token: 'some-token',
        private_key: File.read('spec/fixtures/ssh.private'))

    expect(Rake::Task['ssh_key:provision'].full_comment)
        .to(eq('Provision SSH key on the github/org/repo project'))
  end

  it 'fails if no project slug is provided' do
    define_task(
        api_token: 'some-token',
        private_key: File.read('spec/fixtures/ssh.private'))

    expect {
      Rake::Task['ssh_key:provision'].invoke
    }.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'fails if no API token is provided' do
    define_task(
        project_slug: 'github/org/repo',
        private_key: File.read('spec/fixtures/ssh.private'))

    expect {
      Rake::Task['ssh_key:provision'].invoke
    }.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'fails if no private key is provided' do
    define_task(
        api_token: 'some-token',
        project_slug: 'github/org/repo')

    expect {
      Rake::Task['ssh_key:provision'].invoke
    }.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'defaults to a base URL of https://circleci.com/api' do
    define_task(
        project_slug: 'github/org/repo',
        api_token: 'some-token')

    rake_task = Rake::Task['ssh_key:provision']
    test_task = rake_task.creator

    expect(test_task.base_url)
        .to(eq('https://circleci.com/api'))
  end

  it 'uses the CircleCI client to create the SSH key on the project' do
    project_slug = 'github/org/repo'
    api_token = 'some-token'
    private_key = File.read('spec/fixtures/ssh.private')
    hostname = "github.com"

    client = double('CircleCI client')

    allow(RakeCircleCI::Client)
        .to(receive(:new)
            .with(hash_including(
                project_slug: project_slug,
                api_token: api_token,
                base_url: 'https://circleci.com/api'))
            .and_return(client))

    expect(client).to(receive(:create_ssh_key)
        .with(private_key, hostname: hostname))

    define_task(
        project_slug: project_slug,
        api_token: api_token,
        private_key: private_key,
        hostname: hostname)

    Rake::Task['ssh_key:provision'].invoke
  end

  it 'does not pass a hostname when no parameter value provided' do
    project_slug = 'github/org/repo'
    api_token = 'some-token'
    private_key = File.read('spec/fixtures/ssh.private')

    client = double('CircleCI client')

    allow(RakeCircleCI::Client)
        .to(receive(:new)
            .with(hash_including(
                project_slug: project_slug,
                api_token: api_token,
                base_url: 'https://circleci.com/api'))
            .and_return(client))

    expect(client).to(receive(:create_ssh_key)
        .with(private_key))

    define_task(
        project_slug: project_slug,
        api_token: api_token,
        private_key: private_key)

    Rake::Task['ssh_key:provision'].invoke
  end

  def stub_output
    [:print, :puts].each do |method|
      allow_any_instance_of(Kernel).to(receive(method))
      allow($stdout).to(receive(method))
      allow($stderr).to(receive(method))
    end
  end

  def stub_circle_ci_client
    client = double('CircleCI client', :create_ssh_key => nil)
    allow(RakeCircleCI::Client).to(receive(:new).and_return(client))
  end
end
