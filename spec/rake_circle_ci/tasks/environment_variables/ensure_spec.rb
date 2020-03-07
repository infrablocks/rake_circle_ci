require 'spec_helper'

describe RakeCircleCI::Tasks::EnvironmentVariables::Ensure do
  include_context :rake

  def define_task(opts = {}, &block)
    opts = {
        namespace: :env_vars,
        additional_tasks: [:provision, :destroy]
    }.merge(opts)

    namespace opts[:namespace] do
      opts[:additional_tasks].each do |t|
        task t
      end

      subject.define(opts, &block)
    end
  end

  it 'adds an ensure task in the namespace in which it is created' do
    define_task(
        project_slug: 'github/org/repo')

    expect(Rake::Task.task_defined?('env_vars:ensure'))
        .to(be(true))
  end

  it 'gives the ensure task a description' do
    define_task(
        project_slug: 'github/org/repo')

    expect(Rake::Task['env_vars:ensure'].full_comment)
        .to(eq('Ensure environment variables are configured on the ' +
            'github/org/repo project'))
  end

  it 'fails if no project slug is provided' do
    define_task

    expect {
      Rake::Task['env_vars:ensure'].invoke
    }.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'invokes destroy then provision with any defined arguments' do
    project_slug = 'github/org/repo'

    define_task(
        project_slug: project_slug,
        argument_names: [:thing1, :thing2])

    expect(Rake::Task['env_vars:destroy'])
        .to(receive(:invoke)
            .with('value1', 'value2')
            .ordered)
    expect(Rake::Task['env_vars:provision'])
        .to(receive(:invoke)
            .with('value1', 'value2')
            .ordered)

    Rake::Task['env_vars:ensure'].invoke('value1', 'value2')
  end
end
