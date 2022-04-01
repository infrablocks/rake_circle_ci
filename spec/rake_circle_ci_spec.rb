# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RakeCircleCI do
  it 'has a version number' do
    expect(RakeCircleCI::VERSION).not_to be_nil
  end

  describe 'define_environment_variables_tasks' do
    context 'when instantiating RakeCircleCI::TaskSets::EnvironmentVariables' do
      # rubocop:disable RSpec/MultipleExpectations
      it 'passes the provided block' do
        opts = {
          project_slug: 'github/org/repo'
        }

        block = lambda do |t|
          t.api_token = 'some-token'
          t.environment_variables = {
            THING_ONE: 'value-1',
            THING_TWO: 'value-2'
          }
        end

        allow(RakeCircleCI::TaskSets::EnvironmentVariables)
          .to(receive(:define))

        described_class.define_environment_variables_tasks(opts, &block)

        expect(RakeCircleCI::TaskSets::EnvironmentVariables)
          .to(have_received(:define) do |passed_opts, &passed_block|
            expect(passed_opts).to(eq(opts))
            expect(passed_block).to(eq(block))
          end)
      end
      # rubocop:enable RSpec/MultipleExpectations
    end
  end

  describe 'define_ssh_keys_tasks' do
    context 'when instantiating RakeCircleCI::TaskSets::SSHKeys' do
      # rubocop:disable RSpec/MultipleExpectations
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

        allow(RakeCircleCI::TaskSets::SSHKeys)
          .to(receive(:define))

        described_class.define_ssh_keys_tasks(opts, &block)

        expect(RakeCircleCI::TaskSets::SSHKeys)
          .to(have_received(:define) do |passed_opts, &passed_block|
            expect(passed_opts).to(eq(opts))
            expect(passed_block).to(eq(block))
          end)
      end
      # rubocop:enable RSpec/MultipleExpectations
    end
  end

  describe 'define_project_tasks' do
    context 'when instantiating RakeCircleCI::TaskSets::Project' do
      # rubocop:disable RSpec/MultipleExpectations
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

        allow(RakeCircleCI::TaskSets::Project)
          .to(receive(:define))

        described_class.define_project_tasks(opts, &block)

        expect(RakeCircleCI::TaskSets::Project)
          .to(have_received(:define) do |passed_opts, &passed_block|
            expect(passed_opts).to(eq(opts))
            expect(passed_block).to(eq(block))
          end)
      end
      # rubocop:enable RSpec/MultipleExpectations
    end
  end
end
