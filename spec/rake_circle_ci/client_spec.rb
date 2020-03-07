require 'spec_helper'

describe RakeCircleCI::Client do
  context '#create_env_var' do
    it 'creates an environment variable on the project' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      base_url = 'https://circleci.com/api'
      env_vars_url =
          'https://circleci.com/api/v2/project/github/org/repo/envvar'

      env_var_name = 'THING_ONE'
      env_var_value = 'value-one'

      client = RakeCircleCI::Client.new(
          project_slug: project_slug,
          api_token: api_token,
          base_url: base_url)

      expected_body = JSON.dump(
          name: env_var_name,
          value: env_var_value)
      expected_headers = {
          'Circle-Token': api_token,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
      }

      response = double('create env var response', status: 201)
      expect(Excon)
          .to(receive(:post)
              .with(env_vars_url,
                  body: expected_body,
                  headers: expected_headers)
              .and_return(response))

      client.create_env_var(env_var_name, env_var_value)
    end

    it 'raises an exception on failure' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      path = '/api/v2/project/github/org/repo/envvar'
      base_url = "#{host}/api"
      env_vars_url = "#{host}#{path}"

      env_var_name = 'THING_ONE'
      env_var_value = 'value-one'

      client = RakeCircleCI::Client.new(
          project_slug: project_slug,
          api_token: api_token,
          base_url: base_url)

      expected_body = JSON.dump(
          name: env_var_name,
          value: env_var_value)
      expected_headers = {
          'Circle-Token': api_token,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
      }

      response = double('create env var response',
          status: 400,
          data: {
              host: host,
              path: path,
              reason_phrase: 'Bad Request'
          })
      allow(Excon)
          .to(receive(:post)
              .with(env_vars_url,
                  body: expected_body,
                  headers: expected_headers)
              .and_return(response))

      expect {
        client.create_env_var(env_var_name, env_var_value)
      }.to(raise_error(RuntimeError,
          "Unsuccessful request: #{host}#{path} 400 Bad Request"))
    end
  end
end
