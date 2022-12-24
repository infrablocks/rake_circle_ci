# frozen_string_literal: true

require 'spec_helper'
require 'sshkey'

describe RakeCircleCI::Client do
  describe '#create_env_var' do
    it 'creates an environment variable on the project' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"
      env_var_name = 'THING_ONE'
      env_var_value = 'value-one'

      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      expected_body = create_env_var_request_body(
        env_var_name, env_var_value
      )
      stub_successful_create_env_var_request(
        host, env_vars_path(project_slug), api_token, expected_body
      )

      client.create_env_var(env_var_name, env_var_value)

      expect(Excon)
        .to(have_received(:post)
              .with(env_vars_url(host, project_slug),
                    body: JSON.dump(expected_body),
                    headers: authenticated_headers(api_token)))
    end

    it 'raises an exception on failure' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"

      env_var_name = 'THING_ONE'
      env_var_value = 'value-one'

      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      expected_body = create_env_var_request_body(env_var_name, env_var_value)
      stub_failed_create_env_var_request(
        host, env_vars_path(project_slug), api_token, expected_body
      )

      expect do
        client.create_env_var(env_var_name, env_var_value)
      end.to(raise_error(
               RuntimeError,
               "Unsuccessful request: #{env_vars_url(host, project_slug)} " \
               '400 Bad Request'
             ))
    end
  end

  describe '#delete_env_var' do
    it 'deletes an environment variable from the project' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"

      env_var_name = 'THING_ONE'
      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      stub_successful_delete_env_var_request(
        host, env_var_path(project_slug, env_var_name), api_token
      )

      client.delete_env_var(env_var_name)

      expect(Excon)
        .to(have_received(:delete)
              .with(env_var_url(host, project_slug, env_var_name),
                    headers: authenticated_headers(api_token)))
    end

    it 'raises an exception on failure' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"

      env_var_name = 'THING_ONE'
      env_var_path = env_var_path(project_slug, env_var_name)
      env_var_url = env_var_url(host, project_slug, env_var_name)

      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      stub_failed_delete_env_var_request(host, env_var_path, api_token)

      expect do
        client.delete_env_var(env_var_name)
      end.to(raise_error(
               RuntimeError,
               "Unsuccessful request: #{env_var_url} 400 Bad Request"
             ))
    end
  end

  describe '#find_env_vars' do
    it 'finds all environment variables on the project' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"
      env_var_1_name = 'THING_ONE'
      env_var_2_name = 'THING_TWO'

      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      stub_successful_list_env_vars_request(
        host, env_vars_path(project_slug), api_token,
        [env_var_1_name, env_var_2_name]
      )

      env_vars = client.find_env_vars

      expect(env_vars).to(eq(%w[THING_ONE THING_TWO]))
    end

    it 'raises an exception on failure' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"

      env_vars_path = env_vars_path(project_slug)
      env_vars_url = env_vars_url(host, project_slug)

      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      stub_failed_list_env_vars_request(host, env_vars_path, api_token)

      expect do
        client.find_env_vars
      end.to(raise_error(
               RuntimeError,
               "Unsuccessful request: #{env_vars_url} 400 Bad Request"
             ))
    end
  end

  describe '#delete_env_vars' do
    # rubocop:disable RSpec/MultipleExpectations
    it 'deletes each environment variables on the project' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"

      env_vars_path = env_vars_path(project_slug)

      env_var_1_name = 'THING_ONE'
      env_var_2_name = 'THING_TWO'
      env_var_1_path = env_var_path(project_slug, env_var_1_name)
      env_var_2_path = env_var_path(project_slug, env_var_2_name)

      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      stub_successful_list_env_vars_request(
        host, env_vars_path, api_token,
        [env_var_1_name, env_var_2_name]
      )
      stub_successful_delete_env_var_request(
        host, env_var_1_path, api_token, '1'
      )
      stub_successful_delete_env_var_request(
        host, env_var_2_path, api_token, '2'
      )

      client.delete_env_vars

      expect(Excon)
        .to(have_received(:delete)
              .with(env_var_url(host, project_slug, env_var_1_name),
                    headers: authenticated_headers(api_token)))
      expect(Excon)
        .to(have_received(:delete)
              .with(env_var_url(host, project_slug, env_var_2_name),
                    headers: authenticated_headers(api_token)))
    end
    # rubocop:enable RSpec/MultipleExpectations

    it 'raises an exception on failure' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"

      env_vars_path = env_vars_path(project_slug)

      env_var_1_name = 'THING_ONE'
      env_var_2_name = 'THING_TWO'
      env_var_1_path = env_var_path(project_slug, env_var_1_name)
      env_var_2_path = env_var_path(project_slug, env_var_2_name)

      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      stub_successful_list_env_vars_request(
        host, env_vars_path, api_token,
        [env_var_1_name, env_var_2_name]
      )
      stub_successful_delete_env_var_request(
        host, env_var_1_path, api_token, '1'
      )
      stub_failed_delete_env_var_request(
        host, env_var_2_path, api_token, '2'
      )

      expect do
        client.delete_env_vars
      end.to(raise_error(
               RuntimeError,
               "Unsuccessful request: #{host}#{env_var_2_path} 400 Bad Request"
             ))
    end
  end

  describe '#create_checkout_key' do
    it 'creates a checkout key on the project' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"

      checkout_keys_path = checkout_keys_path(project_slug)

      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      expected_body = create_checkout_key_request_body
      stub_successful_create_checkout_key_request(
        host, checkout_keys_path, api_token, expected_body
      )

      client.create_checkout_key(:deploy_key)

      expect(Excon)
        .to(have_received(:post)
              .with(checkout_keys_url(host, project_slug),
                    body: JSON.dump(expected_body),
                    headers: authenticated_headers(api_token)))
    end

    it 'raises an exception on failure' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"

      checkout_keys_url = checkout_keys_url(host, project_slug)

      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      expected_body = create_checkout_key_request_body
      stub_failed_create_checkout_key_request(
        host, checkout_keys_path(project_slug), api_token, expected_body
      )

      expect do
        client.create_checkout_key(:deploy_key)
      end.to(raise_error(
               RuntimeError,
               "Unsuccessful request: #{checkout_keys_url} 400 Bad Request"
             ))
    end
  end

  describe '#delete_checkout_key' do
    it 'deletes an checkout key from the project' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"

      checkout_key = ssh_key
      fingerprint = checkout_key.fingerprint

      checkout_key_path = checkout_key_path(project_slug, fingerprint)
      checkout_key_url = checkout_key_url(host, project_slug, fingerprint)

      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      stub_successful_delete_checkout_key_request(
        host, checkout_key_path, api_token
      )

      client.delete_checkout_key(fingerprint)

      expect(Excon)
        .to(have_received(:delete)
              .with(checkout_key_url,
                    headers: authenticated_headers(api_token)))
    end

    it 'raises an exception on failure' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"

      fingerprint = ssh_key.fingerprint

      checkout_key_path = checkout_key_path(project_slug, fingerprint)
      checkout_key_url = checkout_key_url(host, project_slug, fingerprint)

      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      stub_failed_delete_checkout_key_request(
        host, checkout_key_path, api_token
      )

      expect do
        client.delete_checkout_key(fingerprint)
      end.to(raise_error(
               RuntimeError,
               "Unsuccessful request: #{checkout_key_url} 400 Bad Request"
             ))
    end
  end

  describe '#find_checkout_keys' do
    it 'finds all checkout keys on the project' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"

      checkout_keys_path = checkout_keys_path(project_slug)

      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      checkout_key1 = {
        key: ssh_key,
        type: 'github-user-key',
        login: 'tobyclemson',
        time: '2020-12-31T19:52:45.088Z'
      }
      checkout_key2 = {
        key: ssh_key,
        type: 'deploy-key',
        time: '2020-12-30T21:12:24.565Z'
      }

      stub_successful_list_checkout_keys_request(
        host, checkout_keys_path, api_token,
        [checkout_key1, checkout_key2]
      )

      checkout_keys = client.find_checkout_keys

      expect(checkout_keys)
        .to(eq([checkout_key_response_body(checkout_key1),
                checkout_key_response_body(checkout_key2)]))
    end

    it 'raises an exception on failure' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"

      checkout_keys_path = checkout_keys_path(project_slug)
      checkout_keys_url = checkout_keys_url(host, project_slug)

      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      stub_failed_list_checkout_keys_request(
        host, checkout_keys_path, api_token
      )

      expect do
        client.find_checkout_keys
      end.to(raise_error(
               RuntimeError,
               "Unsuccessful request: #{checkout_keys_url} 400 Bad Request"
             ))
    end
  end

  describe '#delete_checkout_keys' do
    # rubocop:disable RSpec/MultipleExpectations
    it 'deletes each checkout key on the project' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"

      checkout_keys_path = checkout_keys_path(project_slug)

      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      checkout_key1 = ssh_key
      checkout_key2 = ssh_key

      fingerprint1 = checkout_key1.fingerprint
      fingerprint2 = checkout_key2.fingerprint

      stub_successful_list_checkout_keys_request(
        host, checkout_keys_path, api_token,
        [{ key: checkout_key1 }, { key: checkout_key2 }]
      )
      stub_successful_delete_checkout_key_request(
        host, checkout_key_path(project_slug, fingerprint1), api_token
      )
      stub_successful_delete_checkout_key_request(
        host, checkout_key_path(project_slug, fingerprint2), api_token
      )

      client.delete_checkout_keys

      expect(Excon)
        .to(have_received(:delete)
              .with(checkout_key_url(host, project_slug, fingerprint1),
                    headers: authenticated_headers(api_token)))
      expect(Excon)
        .to(have_received(:delete)
              .with(checkout_key_url(host, project_slug, fingerprint2),
                    headers: authenticated_headers(api_token)))
    end
    # rubocop:enable RSpec/MultipleExpectations

    it 'raises an exception on failure' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"

      checkout_keys_path = checkout_keys_path(project_slug)

      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      checkout_key1 = ssh_key
      checkout_key2 = ssh_key

      fingerprint1 = checkout_key1.fingerprint
      fingerprint2 = checkout_key2.fingerprint

      checkout_key2_url = checkout_key_url(host, project_slug, fingerprint2)

      stub_successful_list_checkout_keys_request(
        host, checkout_keys_path, api_token,
        [{ key: checkout_key1 }, { key: checkout_key2 }]
      )
      stub_successful_delete_checkout_key_request(
        host, checkout_key_path(project_slug, fingerprint1), api_token
      )
      stub_failed_delete_checkout_key_request(
        host, checkout_key_path(project_slug, fingerprint2), api_token
      )

      expect do
        client.delete_checkout_keys
      end.to(raise_error(
               RuntimeError,
               "Unsuccessful request: #{checkout_key2_url} 400 Bad Request"
             ))
    end
  end

  describe '#create_ssh_key' do
    it 'creates an SSH key on the project' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"

      key = ssh_key

      ssh_keys_path = ssh_keys_path(project_slug, api_token)

      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      expected_body = create_ssh_key_request_body(key)
      stub_successful_create_ssh_key_request(
        host, ssh_keys_path, api_token, expected_body
      )

      client.create_ssh_key(key.private_key)

      expect(Excon)
        .to(have_received(:post)
              .with(ssh_keys_url(host, project_slug, api_token),
                    body: JSON.dump(expected_body),
                    headers: authenticated_headers(api_token)))
    end

    it 'passes the hostname when supplied' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"

      key = ssh_key
      hostname = 'github.com'

      ssh_keys_path = ssh_keys_path(project_slug, api_token)
      ssh_keys_url = ssh_keys_url(host, project_slug, api_token)

      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      expected_body = create_ssh_key_request_body(key, hostname)
      stub_successful_create_ssh_key_request(
        host, ssh_keys_path, api_token, expected_body
      )

      client.create_ssh_key(key.private_key, hostname: hostname)

      expect(Excon)
        .to(have_received(:post)
              .with(ssh_keys_url,
                    body: JSON.dump(expected_body),
                    headers: authenticated_headers(api_token)))
    end

    it 'raises an exception on failure' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"

      ssh_keys_path = ssh_keys_path(project_slug, api_token)
      ssh_keys_url = ssh_keys_url(host, project_slug, api_token)

      key = ssh_key
      hostname = 'github.com'

      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      expected_body = create_ssh_key_request_body(key, hostname)
      stub_failed_create_ssh_key_request(
        host, ssh_keys_path, api_token, expected_body
      )

      expect do
        client.create_ssh_key(key.private_key, hostname: hostname)
      end.to(raise_error(
               RuntimeError,
               "Unsuccessful request: #{ssh_keys_url} 400 Bad Request"
             ))
    end
  end

  describe '#delete_ssh_key' do
    it 'deletes an SSH key from the project' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"

      key = ssh_key
      hostname = 'github.com'

      ssh_keys_path = ssh_keys_path(project_slug, api_token)
      ssh_keys_url = ssh_keys_url(host, project_slug, api_token)

      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      expected_body = delete_ssh_key_request_body(key.fingerprint, hostname)
      stub_successful_delete_ssh_key_request(
        host, ssh_keys_path, api_token, expected_body
      )

      client.delete_ssh_key(key.fingerprint, hostname: hostname)

      expect(Excon)
        .to(have_received(:delete)
              .with(ssh_keys_url,
                    body: JSON.dump(expected_body),
                    headers: authenticated_headers(api_token)))
    end

    it 'does not pass a hostname when none supplied' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"

      key = ssh_key

      ssh_keys_path = ssh_keys_path(project_slug, api_token)
      ssh_keys_url = ssh_keys_url(host, project_slug, api_token)

      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      expected_body = delete_ssh_key_request_body(key.fingerprint)
      stub_successful_delete_ssh_key_request(
        host, ssh_keys_path, api_token, expected_body
      )

      client.delete_ssh_key(key.fingerprint)

      expect(Excon)
        .to(have_received(:delete)
              .with(ssh_keys_url,
                    body: JSON.dump(expected_body),
                    headers: authenticated_headers(api_token)))
    end

    it 'raises an exception on failure' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"

      key = ssh_key
      hostname = 'github.com'

      ssh_keys_path = ssh_keys_path(project_slug, api_token)
      ssh_keys_url = ssh_keys_url(host, project_slug, api_token)

      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      expected_body = delete_ssh_key_request_body(key.fingerprint, hostname)
      stub_failed_delete_ssh_key_request(
        host, ssh_keys_path, api_token, expected_body
      )

      expect do
        client.delete_ssh_key(key.fingerprint, hostname: hostname)
      end.to(raise_error(
               RuntimeError,
               "Unsuccessful request: #{ssh_keys_url} 400 Bad Request"
             ))
    end
  end

  describe '#find_ssh_keys' do
    it 'finds all ssh keys on the project' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"

      key1 = ssh_key
      key2 = ssh_key
      hostname1 = 'github.com'

      settings_path = settings_path(project_slug, api_token)

      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      ssh_key1_response_body = ssh_key_response_body(key1, hostname1)
      ssh_key2_response_body = ssh_key_response_body(key2)
      ssh_keys_response_body = ssh_keys_response_body(
        [ssh_key1_response_body, ssh_key2_response_body]
      )
      stub_successful_list_ssh_keys_request(
        host, settings_path, api_token, ssh_keys_response_body
      )

      ssh_keys = client.find_ssh_keys

      expect(ssh_keys)
        .to(eq([ssh_key1_response_body, ssh_key2_response_body]))
    end

    it 'raises an exception on failure' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"

      settings_path = settings_path(project_slug, api_token)
      settings_url = settings_url(host, project_slug, api_token)

      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      stub_failed_list_ssh_keys_request(api_token, host, settings_path)

      expect do
        client.find_ssh_keys
      end.to(raise_error(
               RuntimeError,
               "Unsuccessful request: #{settings_url} 400 Bad Request"
             ))
    end
  end

  describe '#delete_ssh_keys' do
    # rubocop:disable RSpec/MultipleExpectations
    it 'deletes each ssh key on the project' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"

      key1 = ssh_key
      key2 = ssh_key
      hostname1 = 'github.com'

      settings_path = settings_path(project_slug, api_token)
      ssh_keys_path = ssh_keys_path(project_slug, api_token)

      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      expected_body1 = delete_ssh_key_request_body(key1.fingerprint, hostname1)
      expected_body2 = delete_ssh_key_request_body(key2.fingerprint)
      ssh_keys_response_body = ssh_keys_response_body(
        [ssh_key_response_body(key1, hostname1), ssh_key_response_body(key2)]
      )
      stub_successful_list_ssh_keys_request(
        host, settings_path, api_token, ssh_keys_response_body
      )
      stub_successful_delete_ssh_key_request(
        host, ssh_keys_path, api_token, expected_body1
      )
      stub_successful_delete_ssh_key_request(
        host, ssh_keys_path, api_token, expected_body2
      )

      client.delete_ssh_keys

      expect(Excon)
        .to(have_received(:delete)
              .with(ssh_keys_url(host, project_slug, api_token),
                    body: JSON.dump(expected_body1),
                    headers: authenticated_headers(api_token)))
      expect(Excon)
        .to(have_received(:delete)
              .with(ssh_keys_url(host, project_slug, api_token),
                    body: JSON.dump(expected_body2),
                    headers: authenticated_headers(api_token)))
    end
    # rubocop:enable RSpec/MultipleExpectations

    it 'raises an exception on failure' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"

      settings_path = settings_path(project_slug, api_token)
      ssh_keys_path = ssh_keys_path(project_slug, api_token)

      key1 = ssh_key
      key2 = ssh_key
      hostname1 = 'github.com'

      ssh_keys_url = ssh_keys_url(host, project_slug, api_token)

      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      expected_body1 = delete_ssh_key_request_body(key1.fingerprint, hostname1)
      expected_body2 = delete_ssh_key_request_body(key2.fingerprint)

      ssh_keys_response_body = ssh_keys_response_body(
        [ssh_key_response_body(key1, hostname1), ssh_key_response_body(key2)]
      )
      stub_successful_list_ssh_keys_request(
        host, settings_path, api_token, ssh_keys_response_body
      )
      stub_successful_delete_ssh_key_request(
        host, ssh_keys_path, api_token, expected_body1
      )
      stub_failed_delete_ssh_key_request(
        host, ssh_keys_path, api_token, expected_body2
      )

      expect do
        client.delete_ssh_keys
      end.to(raise_error(
               RuntimeError,
               "Unsuccessful request: #{ssh_keys_url} 400 Bad Request"
             ))
    end
  end

  describe '#follow_project' do
    it 'deletes each ssh key on the project' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"

      follow_url = follow_url(host, project_slug, api_token)

      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      expected_headers = authenticated_headers(api_token)

      stub_successful_follow_request(host, project_slug, api_token)

      client.follow_project

      expect(Excon)
        .to(have_received(:post)
              .with(follow_url,
                    headers: expected_headers))
    end

    it 'raises an exception on failure' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = 'https://circleci.com'
      base_url = "#{host}/api"

      follow_url = follow_url(host, project_slug, api_token)

      client = described_class.new(
        project_slug: project_slug,
        api_token: api_token,
        base_url: base_url
      )

      stub_failed_follow_request(api_token, host, project_slug)

      expect do
        client.follow_project
      end.to(raise_error(
               RuntimeError,
               "Unsuccessful request: #{follow_url} 400 Bad Request"
             ))
    end
  end

  def ssh_key
    key = SSHKey.generate
    Struct.new(:public_key, :private_key, :fingerprint)
          .new(key.ssh_public_key,
               key.private_key,
               key.sha1_fingerprint)
  end

  def authenticated_headers(api_token)
    {
      'Circle-Token': api_token,
      'Content-Type': 'application/json',
      Accept: 'application/json'
    }
  end

  def env_vars_path(project_slug)
    "/api/v2/project/#{project_slug}/envvar"
  end

  def env_var_path(project_slug, env_var_name)
    "#{env_vars_path(project_slug)}/#{env_var_name}"
  end

  def checkout_keys_path(project_slug)
    "/api/v1.1/project/#{project_slug}/checkout-key"
  end

  def checkout_key_path(project_slug, fingerprint)
    "#{checkout_keys_path(project_slug)}/#{fingerprint}"
  end

  def ssh_keys_path(project_slug, api_token)
    "/api/v1.1/project/#{project_slug}/ssh-key?circle-token=#{api_token}"
  end

  def settings_path(project_slug, api_token)
    "/api/v1.1/project/#{project_slug}/settings?circle-token=#{api_token}"
  end

  def follow_path(project_slug, api_token)
    "/api/v1.1/project/#{project_slug}/follow?circle-token=#{api_token}"
  end

  def env_vars_url(host, project_slug)
    "#{host}#{env_vars_path(project_slug)}"
  end

  def env_var_url(host, project_slug, env_var_name)
    "#{host}#{env_var_path(project_slug, env_var_name)}"
  end

  def checkout_keys_url(host, project_slug)
    "#{host}#{checkout_keys_path(project_slug)}"
  end

  def checkout_key_url(host, project_slug, fingerprint)
    "#{host}#{checkout_key_path(project_slug, fingerprint)}"
  end

  def ssh_keys_url(host, project_slug, api_token)
    "#{host}#{ssh_keys_path(project_slug, api_token)}"
  end

  def settings_url(host, project_slug, api_token)
    "#{host}#{settings_path(project_slug, api_token)}"
  end

  def follow_url(host, project_slug, api_token)
    "#{host}#{follow_path(project_slug, api_token)}"
  end

  def create_env_var_request_body(env_var_name, env_var_value)
    {
      name: env_var_name,
      value: env_var_value
    }
  end

  def create_checkout_key_request_body
    {
      type: 'deploy-key'
    }
  end

  def create_ssh_key_request_body(key, hostname = nil)
    body = {
      fingerprint: key.fingerprint,
      private_key: key.private_key
    }
    hostname ? body.merge(hostname: hostname) : body
  end

  def delete_ssh_key_request_body(fingerprint, hostname = nil)
    body = {
      fingerprint: fingerprint
    }
    hostname ? body.merge(hostname: hostname) : body
  end

  def bad_request_response_body(host, path)
    {
      host: host,
      path: path,
      reason_phrase: 'Bad Request'
    }
  end

  def env_vars_response_body(env_var_names)
    { items: env_var_names.map { |name| { name: name } } }
  end

  def checkout_key_response_body(opts)
    {
      type: opts[:type] || 'deploy-key',
      ssh_key: opts[:key].public_key,
      fingerprint: opts[:key].fingerprint,
      login: opts[:login] || nil,
      preferred: true,
      time: opts[:time] || '2021-01-01T23:29:01.432Z'
    }
  end

  def checkout_keys_response_body(checkout_keys)
    checkout_keys.map do |checkout_key|
      checkout_key_response_body(checkout_key)
    end
  end

  def successful_delete_checkout_key_response_body
    { message: 'ok' }
  end

  def ssh_key_response_body(key, hostname = nil)
    response = {
      fingerprint: key.fingerprint,
      private_key: key.private_key
    }
    response.merge(hostname: hostname)
  end

  def ssh_keys_response_body(keys)
    {
      ssh_keys: keys
    }
  end

  def follow_response_body
    {
      followed: true
    }
  end

  def response_double(description, opts)
    instance_double(Excon::Response, description, opts)
  end

  def successful_create_env_var_response_double
    response_double('create env var response', status: 201)
  end

  def failed_create_env_var_response_double(host, path)
    response_double(
      'create env var response',
      status: 400,
      data: bad_request_response_body(host, path)
    )
  end

  def successful_delete_env_var_response_double(identifier = nil)
    response_double(
      "delete env var#{identifier ? " #{identifier}" : ''} response",
      status: 201
    )
  end

  def failed_delete_env_var_response_double(host, path, identifier = nil)
    response_double(
      "delete env var#{identifier ? " #{identifier}" : ''} response",
      status: 400,
      data: bad_request_response_body(host, path)
    )
  end

  def successful_list_env_vars_response_double(env_var_names)
    response_double(
      'list env vars response',
      status: 201,
      body: JSON.dump(env_vars_response_body(env_var_names))
    )
  end

  def failed_list_env_vars_response_double(host, path)
    response_double(
      'list env vars response',
      status: 400,
      data: bad_request_response_body(host, path)
    )
  end

  def successful_create_checkout_key_response_double(key)
    response_double(
      'create checkout key response',
      status: 201,
      body: JSON.dump(checkout_key_response_body(key: key))
    )
  end

  def failed_create_checkout_key_response_double(host, checkout_keys_path)
    response_double(
      'create checkout key response',
      status: 400,
      data: bad_request_response_body(host, checkout_keys_path)
    )
  end

  def successful_delete_checkout_key_response_double
    response_double(
      'delete checkout key response',
      status: 200,
      body: JSON.dump(successful_delete_checkout_key_response_body)
    )
  end

  def failed_delete_checkout_key_response_double(host, checkout_key_path)
    response_double(
      'delete checkout key response',
      status: 400,
      data: bad_request_response_body(host, checkout_key_path)
    )
  end

  def successful_list_checkout_keys_response_double(checkout_keys)
    response_double(
      'get checkout keys response',
      status: 200,
      body: JSON.dump(checkout_keys_response_body(checkout_keys))
    )
  end

  def failed_list_checkout_keys_response_double(host, checkout_keys_path)
    response_double(
      'get checkout keys response',
      status: 400,
      data: bad_request_response_body(host, checkout_keys_path)
    )
  end

  def successful_create_ssh_key_response_double
    response_double(
      'create ssh key response',
      status: 201
    )
  end

  def failed_create_ssh_key_response_double(host, ssh_keys_path)
    response_double(
      'create ssh key response',
      status: 400,
      data: bad_request_response_body(host, ssh_keys_path)
    )
  end

  def successful_delete_ssh_key_response_double
    response_double('delete ssh key response', status: 201)
  end

  def failed_delete_ssh_key_response_double(host, ssh_keys_path)
    response_double(
      'delete ssh key response',
      status: 400,
      data: bad_request_response_body(host, ssh_keys_path)
    )
  end

  def successful_list_ssh_keys_response_double(body)
    response_double(
      'get settings response',
      status: 200,
      body: JSON.dump(body)
    )
  end

  def failed_list_ssh_keys_response_double(host, ssh_keys_path)
    response_double(
      'get settings response',
      status: 400,
      data: bad_request_response_body(host, ssh_keys_path)
    )
  end

  def successful_follow_response_double
    response_double(
      'follow project response',
      status: 200,
      body: JSON.dump(follow_response_body)
    )
  end

  def failed_follow_response_double(host, project_slug, api_token)
    response_double(
      'follow project response',
      status: 400,
      data: bad_request_response_body(
        host, follow_path(project_slug, api_token)
      )
    )
  end

  def stub_successful_create_env_var_request(
    host, env_vars_path, api_token, env_var
  )
    allow(Excon)
      .to(receive(:post)
            .with("#{host}#{env_vars_path}",
                  body: JSON.dump(env_var),
                  headers: authenticated_headers(api_token))
            .and_return(successful_create_env_var_response_double))
  end

  def stub_failed_create_env_var_request(
    host, env_vars_path, api_token, body
  )
    allow(Excon)
      .to(receive(:post)
            .with("#{host}#{env_vars_path}",
                  body: JSON.dump(body),
                  headers: authenticated_headers(api_token))
            .and_return(
              failed_create_env_var_response_double(host, env_vars_path)
            ))
  end

  def stub_successful_list_env_vars_request(
    host, env_vars_path, api_token, env_var_names
  )
    allow(Excon)
      .to(receive(:get)
            .with("#{host}#{env_vars_path}",
                  headers: authenticated_headers(api_token))
            .and_return(
              successful_list_env_vars_response_double(env_var_names)
            ))
  end

  def stub_failed_list_env_vars_request(host, env_vars_path, api_token)
    allow(Excon)
      .to(receive(:get)
            .with("#{host}#{env_vars_path}",
                  headers: authenticated_headers(api_token))
            .and_return(failed_list_env_vars_response_double(
                          host, env_vars_path
                        )))
  end

  def stub_successful_delete_env_var_request(
    host, env_var_path, api_token, identifier = nil
  )
    allow(Excon)
      .to(receive(:delete)
            .with("#{host}#{env_var_path}",
                  headers: authenticated_headers(api_token))
            .and_return(
              successful_delete_env_var_response_double(identifier)
            ))
  end

  def stub_failed_delete_env_var_request(
    host, env_var_path, api_token, identifier = nil
  )
    allow(Excon)
      .to(receive(:delete)
            .with("#{host}#{env_var_path}",
                  headers: authenticated_headers(api_token))
            .and_return(
              failed_delete_env_var_response_double(
                host, env_var_path, identifier
              )
            ))
  end

  def stub_successful_create_checkout_key_request(
    host, checkout_keys_path, api_token, expected_body
  )
    allow(Excon)
      .to(receive(:post)
            .with("#{host}#{checkout_keys_path}",
                  body: JSON.dump(expected_body),
                  headers: authenticated_headers(api_token))
            .and_return(
              successful_create_checkout_key_response_double(ssh_key)
            ))
  end

  def stub_failed_create_checkout_key_request(
    host, checkout_keys_path, api_token, expected_body
  )
    allow(Excon)
      .to(receive(:post)
            .with("#{host}#{checkout_keys_path}",
                  body: JSON.dump(expected_body),
                  headers: authenticated_headers(api_token))
            .and_return(
              failed_create_checkout_key_response_double(
                host, checkout_keys_path
              )
            ))
  end

  def stub_successful_delete_checkout_key_request(
    host, checkout_key_path, api_token
  )
    allow(Excon)
      .to(receive(:delete)
            .with("#{host}#{checkout_key_path}",
                  headers: authenticated_headers(api_token))
            .and_return(successful_delete_checkout_key_response_double))
  end

  def stub_failed_delete_checkout_key_request(
    host, checkout_key_path, api_token
  )
    allow(Excon)
      .to(receive(:delete)
            .with("#{host}#{checkout_key_path}",
                  headers: authenticated_headers(api_token))
            .and_return(
              failed_delete_checkout_key_response_double(
                host, checkout_key_path
              )
            ))
  end

  def stub_successful_list_checkout_keys_request(
    host, checkout_keys_path, api_token, checkout_keys
  )
    allow(Excon)
      .to(receive(:get)
            .with("#{host}#{checkout_keys_path}",
                  headers: authenticated_headers(api_token))
            .and_return(
              successful_list_checkout_keys_response_double(
                checkout_keys
              )
            ))
  end

  def stub_failed_list_checkout_keys_request(
    host, checkout_keys_path, api_token
  )
    allow(Excon)
      .to(receive(:get)
            .with("#{host}#{checkout_keys_path}",
                  headers: authenticated_headers(api_token))
            .and_return(
              failed_list_checkout_keys_response_double(
                host, checkout_keys_path
              )
            ))
  end

  def stub_successful_create_ssh_key_request(
    host, ssh_keys_path, api_token, body
  )
    allow(Excon)
      .to(receive(:post)
            .with("#{host}#{ssh_keys_path}",
                  body: JSON.dump(body),
                  headers: authenticated_headers(api_token))
            .and_return(successful_create_ssh_key_response_double))
  end

  def stub_failed_create_ssh_key_request(host, ssh_keys_path, api_token, body)
    allow(Excon)
      .to(receive(:post)
            .with("#{host}#{ssh_keys_path}",
                  body: JSON.dump(body),
                  headers: authenticated_headers(api_token))
            .and_return(failed_create_ssh_key_response_double(
                          host, ssh_keys_path
                        )))
  end

  def stub_successful_delete_ssh_key_request(
    host, ssh_keys_path, api_token, body
  )
    allow(Excon)
      .to(receive(:delete)
            .with("#{host}#{ssh_keys_path}",
                  body: JSON.dump(body),
                  headers: authenticated_headers(api_token))
            .and_return(successful_delete_ssh_key_response_double))
  end

  def stub_failed_delete_ssh_key_request(host, ssh_keys_path, api_token, body)
    allow(Excon)
      .to(receive(:delete)
            .with("#{host}#{ssh_keys_path}",
                  body: JSON.dump(body),
                  headers: authenticated_headers(api_token))
            .and_return(failed_delete_ssh_key_response_double(
                          host, ssh_keys_path
                        )))
  end

  def stub_successful_list_ssh_keys_request(
    host, settings_path, api_token, body
  )
    allow(Excon)
      .to(receive(:get)
            .with("#{host}#{settings_path}",
                  headers: authenticated_headers(api_token))
            .and_return(successful_list_ssh_keys_response_double(
                          body
                        )))
  end

  def stub_failed_list_ssh_keys_request(api_token, host, ssh_keys_path)
    allow(Excon)
      .to(receive(:get)
            .with("#{host}#{ssh_keys_path}",
                  headers: authenticated_headers(api_token))
            .and_return(failed_list_ssh_keys_response_double(
                          host, ssh_keys_path
                        )))
  end

  def stub_successful_follow_request(host, project_slug, api_token)
    allow(Excon)
      .to(receive(:post)
            .with(follow_url(host, project_slug, api_token),
                  headers: authenticated_headers(api_token))
            .and_return(successful_follow_response_double))
  end

  def stub_failed_follow_request(api_token, host, project_slug)
    allow(Excon)
      .to(receive(:post)
            .with(follow_url(host, project_slug, api_token),
                  headers: authenticated_headers(api_token))
            .and_return(failed_follow_response_double(
                          host, project_slug, api_token
                        )))
  end
end
