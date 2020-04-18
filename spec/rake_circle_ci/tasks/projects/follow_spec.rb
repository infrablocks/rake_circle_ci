require 'spec_helper'

describe RakeCircleCI::Tasks::Projects::Follow do
  include_context :rake

  before(:each) do
    stub_output
    stub_circle_ci_client
  end

  def define_task(opts = {}, &block)
    opts = {namespace: :project}.merge(opts)

    namespace opts[:namespace] do
      subject.define(opts, &block)
    end
  end

  it 'adds a follow task in the namespace in which it is created' do
    define_task(
        project_slug: 'github/org/repo',
        api_token: 'some-token')

    expect(Rake::Task.task_defined?('project:follow'))
        .to(be(true))
  end

  it 'gives the follow task a description' do
    define_task(
        project_slug: 'github/org/repo',
        api_token: 'some-token')

    expect(Rake::Task['project:follow'].full_comment)
        .to(eq('Follow the github/org/repo project'))
  end

  it 'fails if no project slug is provided' do
    define_task(
        api_token: 'some-token')

    expect {
      Rake::Task['project:follow'].invoke
    }.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'fails if no API token is provided' do
    define_task(
        project_slug: 'github/org/repo')

    expect {
      Rake::Task['project:follow'].invoke
    }.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'defaults to a base URL of https://circleci.com/api' do
    define_task(
        project_slug: 'github/org/repo',
        api_token: 'some-token')

    rake_task = Rake::Task['project:follow']
    test_task = rake_task.creator

    expect(test_task.base_url)
        .to(eq('https://circleci.com/api'))
  end

  it 'uses the CircleCI client to follow the project' do
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

    expect(client).to(receive(:follow_project))

    define_task(
        project_slug: project_slug,
        api_token: api_token)

    Rake::Task['project:follow'].invoke
  end

  def stub_output
    [:print, :puts].each do |method|
      allow_any_instance_of(Kernel).to(receive(method))
      allow($stdout).to(receive(method))
      allow($stderr).to(receive(method))
    end
  end

  def stub_circle_ci_client
    client = double('CircleCI client', :follow_project => nil)
    allow(RakeCircleCI::Client).to(receive(:new).and_return(client))
  end
end
