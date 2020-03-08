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

    def env_vars_url
      "#{@base_url}/v2/project/#{@project_slug}/envvar"
    end

    def env_var_url(name)
      "#{@base_url}/v2/project/#{@project_slug}/envvar/#{name}"
    end

    def ssh_keys_url
      "#{@base_url}/v1.1/project/#{@project_slug}/ssh-key?" +
          "circle-token=#{@api_token}"
    end
  end
end