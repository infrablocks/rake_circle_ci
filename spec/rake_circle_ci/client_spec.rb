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
      private_key = File.read('spec/fixtures/1.private')
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
      private_key = File.read('spec/fixtures/1.private')
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
      private_key = File.read('spec/fixtures/1.private')
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

  context '#delete_ssh_key' do
    it 'deletes an SSH key from the project' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      base_url = 'https://circleci.com/api'

      private_key = File.read('spec/fixtures/1.private')
      fingerprint = SSHKey.new(private_key).sha1_fingerprint
      hostname = 'github.com'

      ssh_keys_url =
          "#{base_url}/v1.1/project/#{project_slug}/ssh-key?" +
              "circle-token=#{api_token}"

      client = RakeCircleCI::Client.new(
          project_slug: project_slug,
          api_token: api_token,
          base_url: base_url)

      expected_body = JSON.dump(
          fingerprint: fingerprint,
          hostname: hostname
      )
      expected_headers = {
          'Circle-Token': api_token,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
      }

      response = double('delete ssh key response', status: 201)
      expect(Excon)
          .to(receive(:delete)
              .with(ssh_keys_url,
                  body: expected_body,
                  headers: expected_headers)
              .and_return(response))

      client.delete_ssh_key(fingerprint, hostname: hostname)
    end

    it 'does not pass a hostname when none supplied' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      base_url = 'https://circleci.com/api'

      private_key = File.read('spec/fixtures/1.private')
      fingerprint = SSHKey.new(private_key).sha1_fingerprint

      ssh_keys_url =
          "#{base_url}/v1.1/project/#{project_slug}/ssh-key?" +
              "circle-token=#{api_token}"

      client = RakeCircleCI::Client.new(
          project_slug: project_slug,
          api_token: api_token,
          base_url: base_url)

      expected_body = JSON.dump(
          fingerprint: fingerprint
      )
      expected_headers = {
          'Circle-Token': api_token,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
      }

      response = double('delete ssh key response', status: 201)
      expect(Excon)
          .to(receive(:delete)
              .with(ssh_keys_url,
                  body: expected_body,
                  headers: expected_headers)
              .and_return(response))

      client.delete_ssh_key(fingerprint)
    end

    it 'raises an exception on failure' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      path = "/api/v1.1/project/#{project_slug}/ssh-key?" +
              "circle-token=#{api_token}"
      base_url = "#{host}/api"

      private_key = File.read('spec/fixtures/1.private')
      fingerprint = SSHKey.new(private_key).sha1_fingerprint
      hostname = 'github.com'

      ssh_keys_url = "#{host}#{path}"

      client = RakeCircleCI::Client.new(
          project_slug: project_slug,
          api_token: api_token,
          base_url: base_url)

      expected_body = JSON.dump(
          fingerprint: fingerprint,
          hostname: hostname
      )
      expected_headers = {
          'Circle-Token': api_token,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
      }

      response = double('delete ssh key response',
          status: 400,
          data: {
              host: host,
              path: path,
              reason_phrase: 'Bad Request'
          })
      allow(Excon)
          .to(receive(:delete)
              .with(ssh_keys_url,
                  body: expected_body,
                  headers: expected_headers)
              .and_return(response))

      expect {
        client.delete_ssh_key(fingerprint, hostname: hostname)
      }.to(raise_error(RuntimeError,
          "Unsuccessful request: #{host}#{path} 400 Bad Request"))
    end
  end

  context '#find_ssh_keys' do
    it 'finds all ssh keys on the project' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      base_url = 'https://circleci.com/api'

      private_key_1 = File.read('spec/fixtures/1.private')
      private_key_2 = File.read('spec/fixtures/2.private')
      fingerprint_1 = SSHKey.new(private_key_1).sha1_fingerprint
      fingerprint_2 = SSHKey.new(private_key_2).sha1_fingerprint
      hostname_1 = 'github.com'

      settings_url =
          "#{base_url}/v1.1/project/#{project_slug}/settings?" +
              "circle-token=#{api_token}"

      client = RakeCircleCI::Client.new(
          project_slug: project_slug,
          api_token: api_token,
          base_url: base_url)

      expected_headers = {
          'Circle-Token': api_token,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
      }

      response = double('get settings response',
          status: 200,
          body: JSON.dump({
              ssh_keys: [
                  {
                      fingerprint: fingerprint_1,
                      hostname: hostname_1,
                      private_key: private_key_1
                  },
                  {
                      fingerprint: fingerprint_2,
                      private_key: private_key_2
                  },
              ]
          }))
      expect(Excon)
          .to(receive(:get)
              .with(settings_url,
                  headers: expected_headers)
              .and_return(response))

      ssh_keys = client.find_ssh_keys

      expect(ssh_keys)
          .to(eq([
              {fingerprint: fingerprint_1, hostname: hostname_1},
              {fingerprint: fingerprint_2, hostname: nil},
          ]))
    end

    it 'raises an exception on failure' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      path = '/api/v1.1/project/github/org/repo/settings?' +
          "circle-token=#{api_token}"
      base_url = "#{host}/api"

      settings_url = "#{host}#{path}"

      client = RakeCircleCI::Client.new(
          project_slug: project_slug,
          api_token: api_token,
          base_url: base_url)

      expected_headers = {
          'Circle-Token': api_token,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
      }

      response = double('get settings response',
          status: 400,
          data: {
              host: host,
              path: path,
              reason_phrase: 'Bad Request'
          })
      allow(Excon)
          .to(receive(:get)
              .with(settings_url,
                  headers: expected_headers)
              .and_return(response))

      expect {
        client.find_ssh_keys
      }.to(raise_error(RuntimeError,
          "Unsuccessful request: #{host}#{path} 400 Bad Request"))
    end
  end

  context '#delete_ssh_keys' do
    it 'deletes each ssh key on the project' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      base_url = 'https://circleci.com/api'

      private_key_1 = File.read('spec/fixtures/1.private')
      private_key_2 = File.read('spec/fixtures/2.private')
      fingerprint_1 = SSHKey.new(private_key_1).sha1_fingerprint
      fingerprint_2 = SSHKey.new(private_key_2).sha1_fingerprint
      hostname_1 = 'github.com'

      settings_url =
          "#{base_url}/v1.1/project/#{project_slug}/settings?" +
              "circle-token=#{api_token}"
      ssh_keys_url =
          "#{base_url}/v1.1/project/#{project_slug}/ssh-key?" +
              "circle-token=#{api_token}"

      client = RakeCircleCI::Client.new(
          project_slug: project_slug,
          api_token: api_token,
          base_url: base_url)

      expected_headers = {
          'Circle-Token': api_token,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
      }
      expected_body_1 = JSON.dump(
          fingerprint: fingerprint_1,
          hostname: hostname_1
      )
      expected_body_2 = JSON.dump(
          fingerprint: fingerprint_2
      )

      expect(Excon)
          .to(receive(:get)
              .with(settings_url,
                  headers: expected_headers)
              .and_return(double('get settings response',
                  status: 200,
                  body: JSON.dump({
                      ssh_keys: [
                          {
                              fingerprint: fingerprint_1,
                              hostname: hostname_1,
                              private_key: private_key_1
                          },
                          {
                              fingerprint: fingerprint_2,
                              private_key: private_key_2
                          },
                      ]
                  }))))
      expect(Excon)
          .to(receive(:delete)
              .with(ssh_keys_url,
                  body: expected_body_1,
                  headers: expected_headers)
              .and_return(double('delete ssh key response', status: 201)))
      expect(Excon)
          .to(receive(:delete)
              .with(ssh_keys_url,
                  body: expected_body_2,
                  headers: expected_headers)
              .and_return(double('delete ssh key response', status: 201)))

      client.delete_ssh_keys
    end

    it 'raises an exception on failure' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      settings_path = '/api/v1.1/project/github/org/repo/settings?' +
          "circle-token=#{api_token}"
      ssh_keys_path = '/api/v1.1/project/github/org/repo/ssh-key?' +
          "circle-token=#{api_token}"
      base_url = "#{host}/api"

      private_key_1 = File.read('spec/fixtures/1.private')
      private_key_2 = File.read('spec/fixtures/2.private')
      fingerprint_1 = SSHKey.new(private_key_1).sha1_fingerprint
      fingerprint_2 = SSHKey.new(private_key_2).sha1_fingerprint
      hostname_1 = 'github.com'

      settings_url = "#{host}#{settings_path}"
      ssh_keys_url = "#{host}#{ssh_keys_path}"

      client = RakeCircleCI::Client.new(
          project_slug: project_slug,
          api_token: api_token,
          base_url: base_url)

      expected_headers = {
          'Circle-Token': api_token,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
      }
      expected_body_1 = JSON.dump(
          fingerprint: fingerprint_1,
          hostname: hostname_1
      )
      expected_body_2 = JSON.dump(
          fingerprint: fingerprint_2
      )

      expect(Excon)
          .to(receive(:get)
              .with(settings_url,
                  headers: expected_headers)
              .and_return(double('get settings response',
                  status: 200,
                  body: JSON.dump({
                      ssh_keys: [
                          {
                              fingerprint: fingerprint_1,
                              hostname: hostname_1,
                              private_key: private_key_1
                          },
                          {
                              fingerprint: fingerprint_2,
                              private_key: private_key_2
                          },
                      ]
                  }))))
      expect(Excon)
          .to(receive(:delete)
              .with(ssh_keys_url,
                  body: expected_body_1,
                  headers: expected_headers)
              .and_return(double('delete ssh key response', status: 201)))
      expect(Excon)
          .to(receive(:delete)
              .with(ssh_keys_url,
                  body: expected_body_2,
                  headers: expected_headers)
              .and_return(double('delete ssh key response',
                  status: 400,
                  data: {
                      host: host,
                      path: ssh_keys_path,
                      reason_phrase: 'Bad Request'
                  })))

      expect {
        client.delete_ssh_keys
      }.to(raise_error(RuntimeError,
          "Unsuccessful request: #{ssh_keys_url} 400 Bad Request"))
    end
  end

  context '#follow_project' do
    it 'deletes each ssh key on the project' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      base_url = 'https://circleci.com/api'

      follow_url =
          "#{base_url}/v1.1/project/#{project_slug}/follow?" +
              "circle-token=#{api_token}"

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
          .to(receive(:post)
              .with(follow_url,
                  headers: expected_headers)
              .and_return(double('follow project response',
                  status: 200,
                  body: JSON.dump({
                      followed: true
                  }))))

      client.follow_project
    end

    it 'raises an exception on failure' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      follow_path = '/api/v1.1/project/github/org/repo/follow?' +
          "circle-token=#{api_token}"
      base_url = "#{host}/api"

      follow_url = "#{host}#{follow_path}"

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
          .to(receive(:post)
              .with(follow_url,
                  headers: expected_headers)
              .and_return(double('follow project response',
                  status: 400,
                  data: {
                      host: host,
                      path: follow_path,
                      reason_phrase: 'Bad Request'
                  })))

      expect {
        client.follow_project
      }.to(raise_error(RuntimeError,
          "Unsuccessful request: #{follow_url} 400 Bad Request"))
    end
  end
end
