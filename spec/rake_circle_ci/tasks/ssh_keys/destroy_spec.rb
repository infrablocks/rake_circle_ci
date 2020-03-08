require 'spec_helper'

describe RakeCircleCI::Tasks::SSHKeys::Destroy do
  include_context :rake

  before(:each) do
    stub_output
    stub_circle_ci_client
  end

  def define_task(opts = {}, &block)
    opts = {namespace: :ssh_keys}.merge(opts)

    namespace opts[:namespace] do
      subject.define(opts, &block)
    end
  end

  it 'adds a destroy task in the namespace in which it is created' do
    define_task(
        project_slug: 'github/org/repo',
        api_token: 'some-token')

    expect(Rake::Task.task_defined?('ssh_keys:destroy'))
        .to(be(true))
  end

  it 'gives the destroy task a description' do
    define_task(
        project_slug: 'github/org/repo',
        api_token: 'some-token')

    expect(Rake::Task['ssh_keys:destroy'].full_comment)
        .to(eq('Destroy SSH keys in the github/org/repo project'))
  end

  it 'fails if no project slug is provided' do
    define_task(
        api_token: 'some-token')

    expect {
      Rake::Task['ssh_keys:destroy'].invoke
    }.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'fails if no API token is provided' do
    define_task(
        project_slug: 'github/org/repo')

    expect {
      Rake::Task['ssh_keys:destroy'].invoke
    }.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'defaults to a base URL of https://circleci.com/api' do
    define_task(
        project_slug: 'github/org/repo',
        api_token: 'some-token')

    rake_task = Rake::Task['ssh_keys:destroy']
    test_task = rake_task.creator

    expect(test_task.base_url)
        .to(eq('https://circleci.com/api'))
  end

  it 'uses the CircleCI client to delete the SSH keys from ' +
      'the project' do
    project_slug = 'github/org/repo'
    api_token = 'some-token'

    client = double('CircleCI client')

    allow(RakeCircleCI::Client)
        .to(receive(:new)
            .with(hash_including(
                project_slug: project_slug,
                api_token: api_token,
                base_url: 'https://circleci.com/api'))
            .and_return(client))

    expect(client).to(receive(:delete_ssh_keys))

    define_task(
        project_slug: project_slug,
        api_token: api_token)

    Rake::Task['ssh_keys:destroy'].invoke
  end

  def stub_output
    [:print, :puts].each do |method|
      allow_any_instance_of(Kernel).to(receive(method))
      allow($stdout).to(receive(method))
      allow($stderr).to(receive(method))
    end
  end

  def stub_circle_ci_client
    client = double('CircleCI client', :delete_ssh_keys => nil)
    allow(RakeCircleCI::Client).to(receive(:new).and_return(client))
  end
end
