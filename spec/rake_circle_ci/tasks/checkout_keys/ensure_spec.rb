# frozen_string_literal: true

require 'spec_helper'

describe RakeCircleCI::Tasks::CheckoutKeys::Ensure do
  include_context 'rake'

  def define_task(opts = {}, &block)
    opts = {
      namespace: :checkout_keys,
      additional_tasks: %i[provision destroy]
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
      project_slug: 'github/org/repo'
    )

    expect(Rake.application)
      .to(have_task_defined('checkout_keys:ensure'))
  end

  it 'gives the ensure task a description' do
    define_task(
      project_slug: 'github/org/repo'
    )

    expect(Rake::Task['checkout_keys:ensure'].full_comment)
      .to(eq('Ensure checkout keys are configured on the ' \
             'github/org/repo project'))
  end

  it 'fails if no project slug is provided' do
    define_task

    expect do
      Rake::Task['checkout_keys:ensure'].invoke
    end.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  # rubocop:disable RSpec/MultipleExpectations
  it 'invokes destroy then provision with any defined arguments' do
    project_slug = 'github/org/repo'

    define_task(
      project_slug:,
      argument_names: %i[thing1 thing2]
    )

    allow(Rake::Task['checkout_keys:destroy'])
      .to(receive(:invoke))
    allow(Rake::Task['checkout_keys:provision'])
      .to(receive(:invoke))

    Rake::Task['checkout_keys:ensure'].invoke('value1', 'value2')

    expect(Rake::Task['checkout_keys:destroy'])
      .to(have_received(:invoke)
            .with('value1', 'value2')
            .ordered)
    expect(Rake::Task['checkout_keys:provision'])
      .to(have_received(:invoke)
            .with('value1', 'value2')
            .ordered)
  end
  # rubocop:enable RSpec/MultipleExpectations
end
