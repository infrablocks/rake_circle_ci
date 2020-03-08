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
end
