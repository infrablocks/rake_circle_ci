require 'json'
require 'excon'
require 'sshkey'

module RakeCircleCI
  class Client
    def initialize(opts)
      @base_url = opts[:base_url]
      @api_token = opts[:api_token]
      @project_slug = opts[:project_slug]
    end

    def follow_project
      assert_successful(Excon.post(follow_url, headers: headers))
    end

    def find_env_vars
      response = assert_successful(Excon.get(env_vars_url, headers: headers))
      body = JSON.parse(response.body)
      env_vars = body["items"].map { |item| item["name"] }

      env_vars
    end

    def create_env_var(name, value)
      body = JSON.dump(name: name, value: value)
      assert_successful(
          Excon.post(env_vars_url, body: body, headers: headers))
    end

    def delete_env_var(name)
      assert_successful(Excon.delete(env_var_url(name), headers: headers))
    end

    def delete_env_vars
      env_vars = find_env_vars
      env_vars.each do |env_var|
        delete_env_var(env_var)
      end
    end

    def find_ssh_keys
      response = assert_successful(Excon.get(settings_url, headers: headers))
      body = JSON.parse(response.body, symbolize_names: true)
      ssh_keys = body[:ssh_keys]

      ssh_keys
    end

    def create_ssh_key(private_key, opts = {})
      body = {
          fingerprint: SSHKey.new(private_key).sha1_fingerprint,
          private_key: private_key,
      }
      body = body.merge(hostname: opts[:hostname]) if opts[:hostname]
      body = JSON.dump(body)
      assert_successful(
          Excon.post(ssh_keys_url, body: body, headers: headers))
    end

    def delete_ssh_key(fingerprint, opts = {})
      body = {
          fingerprint: fingerprint
      }
      body = body.merge(hostname: opts[:hostname]) if opts[:hostname]
      body = JSON.dump(body)
      assert_successful(
          Excon.delete(ssh_keys_url, body: body, headers: headers))
    end

    def delete_ssh_keys
      ssh_keys = find_ssh_keys
      ssh_keys.each do |ssh_key|
        fingerprint = ssh_key[:fingerprint]
        hostname = ssh_key[:hostname]
        options = hostname && {hostname: hostname}
        args = [fingerprint, options].compact
        delete_ssh_key(*args)
      end
    end

    def find_checkout_keys
      response = assert_successful(
          Excon.get(checkout_keys_url, headers: headers))
      checkout_keys = JSON.parse(response.body, symbolize_names: true)

      checkout_keys
    end

    def delete_checkout_key(fingerprint)
      assert_successful(
          Excon.delete(checkout_key_url(fingerprint), headers: headers))
    end

    def delete_checkout_keys
      checkout_keys = find_checkout_keys
      checkout_keys.each do |checkout_key|
        delete_checkout_key(checkout_key[:fingerprint])
      end
    end

    private

    def headers
      {
          "Circle-Token": @api_token,
          "Content-Type": "application/json",
          "Accept": "application/json"
      }
    end

    def assert_successful(response)
      unless response.status >= 200 && response.status < 300
        host = response.data[:host]
        path = response.data[:path]
        status = response.status
        reason = response.data[:reason_phrase]
        raise "Unsuccessful request: #{host}#{path} #{status} #{reason}"
      end
      response
    end

    def follow_url
      "#{@base_url}/v1.1/project/#{@project_slug}/follow?" +
          "circle-token=#{@api_token}"
    end

    def env_vars_url
      "#{@base_url}/v2/project/#{@project_slug}/envvar"
    end

    def env_var_url(name)
      "#{@base_url}/v2/project/#{@project_slug}/envvar/#{name}"
    end

    def settings_url
      "#{@base_url}/v1.1/project/#{@project_slug}/settings?" +
          "circle-token=#{@api_token}"
    end

    def ssh_keys_url
      "#{@base_url}/v1.1/project/#{@project_slug}/ssh-key?" +
          "circle-token=#{@api_token}"
    end

    def checkout_keys_url
      "#{@base_url}/v1.1/project/#{@project_slug}/checkout-key"
    end

    def checkout_key_url(fingerprint)
      "#{@base_url}/v1.1/project/#{@project_slug}/checkout-key/#{fingerprint}"
    end
  end
end
