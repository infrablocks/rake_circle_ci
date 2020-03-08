require 'spec_helper'

RSpec.describe RakeCircleCI do
  it 'has a version number' do
    expect(RakeCircleCI::VERSION).not_to be nil
  end

  context 'define_environment_variables_tasks' do
    context 'when instantiating RakeCircleCI::TaskSets::EnvironmentVariables' do
      it 'passes the provided block' do
        opts = {
            project_slug: 'github/org/repo'
        }

        block = lambda do |t|
          t.api_token = 'some-token'
          t.environment_variables = {
              THING_ONE: 'value-1',
              THING_TWO: 'value-2',
          }
        end

        expect(RakeCircleCI::TaskSets::EnvironmentVariables)
            .to(receive(:define) do |passed_opts, &passed_block|
              expect(passed_opts).to(eq(opts))
              expect(passed_block).to(eq(block))
            end)

        RakeCircleCI.define_environment_variables_tasks(opts, &block)
      end
    end
  end

  context 'define_ssh_keys_tasks' do
    context 'when instantiating RakeCircleCI::TaskSets::SSHKeys' do
      it 'passes the provided block' do
        opts = {
            project_slug: 'github/org/repo'
        }

        block = lambda do |t|
          t.api_token = 'some-token'
          t.ssh_keys = [
              {
                  private_key: File.read('spec/fixtures/1.private'),
                  hostname: 'github.com'
              },
              {
                  private_key: File.read('spec/fixtures/2.private')
              }
          ]
        end

        expect(RakeCircleCI::TaskSets::SSHKeys)
            .to(receive(:define) do |passed_opts, &passed_block|
              expect(passed_opts).to(eq(opts))
              expect(passed_block).to(eq(block))
            end)

        RakeCircleCI.define_ssh_keys_tasks(opts, &block)
      end
    end
  end

  context 'define_project_tasks' do
    context 'when instantiating RakeCircleCI::TaskSets::Project' do
      it 'passes the provided block' do
        opts = {
            project_slug: 'github/org/repo'
        }

        block = lambda do |t|
          t.api_token = 'some-token'
          t.environment_variables = {
              THING_ONE: 'value-1'
          }
          t.ssh_keys = [
              {
                  private_key: File.read('spec/fixtures/1.private'),
                  hostname: 'github.com'
              },
              {
                  private_key: File.read('spec/fixtures/2.private')
              }
          ]
        end

        expect(RakeCircleCI::TaskSets::Project)
            .to(receive(:define) do |passed_opts, &passed_block|
              expect(passed_opts).to(eq(opts))
              expect(passed_block).to(eq(block))
            end)

        RakeCircleCI.define_project_tasks(opts, &block)
      end
    end
  end
end
