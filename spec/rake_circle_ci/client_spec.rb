require 'spec_helper'
require 'sshkey'

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

  context '#delete_env_var' do
    it 'deletes an environment variable from the project' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      base_url = 'https://circleci.com/api'

      env_var_name = 'THING_ONE'
      env_var_url =
          "#{base_url}/v2/project/#{project_slug}/envvar/#{env_var_name}"

      client = RakeCircleCI::Client.new(
          project_slug: project_slug,
          api_token: api_token,
          base_url: base_url)

      expected_headers = {
          'Circle-Token': api_token,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
      }

      response = double('delete env var response', status: 201)
      expect(Excon)
          .to(receive(:delete)
              .with(env_var_url,
                  headers: expected_headers)
              .and_return(response))

      client.delete_env_var(env_var_name)
    end

    it 'raises an exception on failure' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      path = '/api/v2/project/github/org/repo/envvar/THING_ONE'
      base_url = "#{host}/api"

      env_var_name = 'THING_ONE'
      env_var_url = "#{host}#{path}"

      client = RakeCircleCI::Client.new(
          project_slug: project_slug,
          api_token: api_token,
          base_url: base_url)

      expected_headers = {
          'Circle-Token': api_token,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
      }

      response = double('delete env var response',
          status: 400,
          data: {
              host: host,
              path: path,
              reason_phrase: 'Bad Request'
          })
      allow(Excon)
          .to(receive(:delete)
              .with(env_var_url,
                  headers: expected_headers)
              .and_return(response))

      expect {
        client.delete_env_var(env_var_name)
      }.to(raise_error(RuntimeError,
          "Unsuccessful request: #{host}#{path} 400 Bad Request"))
    end
  end

  context '#find_env_vars' do
    it 'finds all environment variables on the project' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      base_url = 'https://circleci.com/api'

      env_vars_url =
          'https://circleci.com/api/v2/project/github/org/repo/envvar'

      client = RakeCircleCI::Client.new(
          project_slug: project_slug,
          api_token: api_token,
          base_url: base_url)

      expected_headers = {
          'Circle-Token': api_token,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
      }

      response = double('list env vars response',
          status: 201,
          body: JSON.dump({
              items: [
                  {name: "THING_ONE"},
                  {name: "THING_TWO"},
              ]
          }))
      expect(Excon)
          .to(receive(:get)
              .with(env_vars_url,
                  headers: expected_headers)
              .and_return(response))

      env_vars = client.find_env_vars

      expect(env_vars).to(eq(["THING_ONE", "THING_TWO"]))
    end

    it 'raises an exception on failure' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      path = '/api/v2/project/github/org/repo/envvar'
      base_url = "#{host}/api"

      env_vars_url = "#{host}#{path}"

      client = RakeCircleCI::Client.new(
          project_slug: project_slug,
          api_token: api_token,
          base_url: base_url)

      expected_headers = {
          'Circle-Token': api_token,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
      }

      response = double('delete env var response',
          status: 400,
          data: {
              host: host,
              path: path,
              reason_phrase: 'Bad Request'
          })
      allow(Excon)
          .to(receive(:get)
              .with(env_vars_url,
                  headers: expected_headers)
              .and_return(response))

      expect {
        client.find_env_vars
      }.to(raise_error(RuntimeError,
          "Unsuccessful request: #{host}#{path} 400 Bad Request"))
    end
  end

  context '#delete_env_vars' do
    it 'deletes each environment variables on the project' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      base_url = 'https://circleci.com/api'

      env_vars_url = "#{base_url}/v2/project/github/org/repo/envvar"
      env_var_1_url = "#{env_vars_url}/THING_ONE"
      env_var_2_url = "#{env_vars_url}/THING_TWO"

      client = RakeCircleCI::Client.new(
          project_slug: project_slug,
          api_token: api_token,
          base_url: base_url)

      expected_headers = {
          'Circle-Token': api_token,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
      }

      expect(Excon)
          .to(receive(:get)
              .with(env_vars_url,
                  headers: expected_headers)
              .and_return(
                  double('list env vars response',
                      status: 201,
                      body: JSON.dump({
                          items: [
                              {name: "THING_ONE"},
                              {name: "THING_TWO"},
                          ]
                      }))))
      expect(Excon)
          .to(receive(:delete)
              .with(env_var_1_url,
                  headers: expected_headers)
              .and_return(double('delete env var 1 response', status: 201)))
      expect(Excon)
          .to(receive(:delete)
              .with(env_var_2_url,
                  headers: expected_headers)
              .and_return(double('delete env var 1 response', status: 201)))

      client.delete_env_vars
    end

    it 'raises an exception on failure' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_path = '/api/v2/project/github/org/repo/envvar'
      base_url = "#{host}/api"

      env_vars_url = "#{host}#{base_path}"
      env_var_1_url = "#{env_vars_url}/THING_ONE"
      env_var_2_url = "#{env_vars_url}/THING_TWO"

      client = RakeCircleCI::Client.new(
          project_slug: project_slug,
          api_token: api_token,
          base_url: base_url)

      expected_headers = {
          'Circle-Token': api_token,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
      }

      expect(Excon)
          .to(receive(:get)
              .with(env_vars_url,
                  headers: expected_headers)
              .and_return(
                  double('list env vars response',
                      status: 201,
                      body: JSON.dump({
                          items: [
                              {name: "THING_ONE"},
                              {name: "THING_TWO"},
                          ]
                      }))))
      expect(Excon)
          .to(receive(:delete)
              .with(env_var_1_url,
                  headers: expected_headers)
              .and_return(double('delete env var 1 response', status: 201)))
      expect(Excon)
          .to(receive(:delete)
              .with(env_var_2_url,
                  headers: expected_headers)
              .and_return(double('delete env var 1 response',
                  status: 400,
                  data: {
                      host: host,
                      path: "#{base_path}/THING_TWO",
                      reason_phrase: 'Bad Request'
                  })))

      expect {
        client.delete_env_vars
      }.to(raise_error(RuntimeError,
          "Unsuccessful request: #{env_var_2_url} 400 Bad Request"))
    end
  end

  context '#create_ssh_key' do
    it 'creates an SSH key on the project' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      base_url = 'https://circleci.com/api'
      private_key = File.read('spec/fixtures/ssh.private')
      ssh_key = SSHKey.new(private_key)

      ssh_keys_url =
          'https://circleci.com/api/v1.1/project/github/org/repo/ssh-key?' +
              "circle-token=#{api_token}"

      client = RakeCircleCI::Client.new(
          project_slug: project_slug,
          api_token: api_token,
          base_url: base_url)

      expected_body = JSON.dump(
          fingerprint: ssh_key.sha1_fingerprint,
          private_key: ssh_key.private_key)
      expected_headers = {
          'Circle-Token': api_token,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
      }

      response = double('create ssh key response', status: 201)
      expect(Excon)
          .to(receive(:post)
              .with(ssh_keys_url,
                  body: expected_body,
                  headers: expected_headers)
              .and_return(response))

      client.create_ssh_key(private_key)
    end

    it 'passes the hostname when supplied' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      base_url = 'https://circleci.com/api'
      private_key = File.read('spec/fixtures/ssh.private')
      hostname = "github.com"
      ssh_key = SSHKey.new(private_key)

      ssh_keys_url =
          'https://circleci.com/api/v1.1/project/github/org/repo/ssh-key?' +
              "circle-token=#{api_token}"

      client = RakeCircleCI::Client.new(
          project_slug: project_slug,
          api_token: api_token,
          base_url: base_url)

      expected_body = JSON.dump(
          fingerprint: ssh_key.sha1_fingerprint,
          private_key: ssh_key.private_key,
          hostname: hostname)
      expected_headers = {
          'Circle-Token': api_token,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
      }

      response = double('create ssh key response', status: 201)
      expect(Excon)
          .to(receive(:post)
              .with(ssh_keys_url,
                  body: expected_body,
                  headers: expected_headers)
              .and_return(response))

      client.create_ssh_key(private_key, hostname: hostname)
    end

    it 'raises an exception on failure' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      path = "/api/v1.1/project/github/org/repo/ssh-key?" +
          "circle-token=#{api_token}"
      base_url = "#{host}/api"
      private_key = File.read('spec/fixtures/ssh.private')
      hostname = "github.com"
      ssh_key = SSHKey.new(private_key)

      ssh_keys_url = "#{host}#{path}"

      client = RakeCircleCI::Client.new(
          project_slug: project_slug,
          api_token: api_token,
          base_url: base_url)

      expected_body = JSON.dump(
          fingerprint: ssh_key.sha1_fingerprint,
          private_key: ssh_key.private_key,
          hostname: hostname)
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
              .with(ssh_keys_url,
                  body: expected_body,
                  headers: expected_headers)
              .and_return(response))

      expect {
        client.create_ssh_key(private_key, hostname: hostname)
      }.to(raise_error(RuntimeError,
          "Unsuccessful request: #{host}#{path} 400 Bad Request"))
    end
  end
end
