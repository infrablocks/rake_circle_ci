# frozen_string_literal: true

require 'json'
require 'excon'
require 'sshkey'

module RakeCircleCI
  class URLs
    def initialize(opts)
      @base_url = opts[:base_url]
      @api_token = opts[:api_token]
      @project_slug = opts[:project_slug]
    end

    def follow_url
      "#{@base_url}/v1.1/project/#{@project_slug}/follow?" \
        "circle-token=#{@api_token}"
    end

    def env_vars_url
      "#{@base_url}/v2/project/#{@project_slug}/envvar"
    end

    def env_var_url(name)
      "#{@base_url}/v2/project/#{@project_slug}/envvar/#{name}"
    end

    def settings_url
      "#{@base_url}/v1.1/project/#{@project_slug}/settings?" \
        "circle-token=#{@api_token}"
    end

    def ssh_keys_url
      "#{@base_url}/v1.1/project/#{@project_slug}/ssh-key?" \
        "circle-token=#{@api_token}"
    end

    def checkout_keys_url
      "#{@base_url}/v1.1/project/#{@project_slug}/checkout-key"
    end

    def checkout_key_url(fingerprint)
      "#{@base_url}/v1.1/project/#{@project_slug}/checkout-key/#{fingerprint}"
    end
  end

  class HTTPClient
    def get(url, opts)
      assert_successful(Excon.get(url, opts))
    end

    def post(url, opts)
      assert_successful(Excon.post(url, opts))
    end

    def delete(url, opts)
      assert_successful(Excon.delete(url, opts))
    end

    private

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
  end

  class Client
    def initialize(opts)
      @urls = URLs.new(opts)
      @api_token = opts[:api_token]
      @http = HTTPClient.new
    end

    def follow_project
      @http.post(@urls.follow_url, headers: headers)
    end

    def find_env_vars
      response = @http.get(@urls.env_vars_url, headers: headers)
      body = JSON.parse(response.body)
      body['items'].map { |item| item['name'] }
    end

    def create_env_var(name, value)
      body = JSON.dump(name: name, value: value)
      @http.post(@urls.env_vars_url, body: body, headers: headers)
    end

    def delete_env_var(name)
      @http.delete(@urls.env_var_url(name), headers: headers)
    end

    def delete_env_vars
      env_vars = find_env_vars
      env_vars.each do |env_var|
        delete_env_var(env_var)
      end
    end

    def find_ssh_keys
      response = @http.get(@urls.settings_url, headers: headers)
      body = JSON.parse(response.body, symbolize_names: true)
      body[:ssh_keys]
    end

    def create_ssh_key(private_key, opts = {})
      body = {
        fingerprint: SSHKey.new(private_key).sha1_fingerprint,
        private_key: private_key
      }
      body = body.merge(hostname: opts[:hostname]) if opts[:hostname]
      body = JSON.dump(body)
      @http.post(@urls.ssh_keys_url, body: body, headers: headers)
    end

    def delete_ssh_key(fingerprint, opts = {})
      body = {
        fingerprint: fingerprint
      }
      body = body.merge(hostname: opts[:hostname]) if opts[:hostname]
      body = JSON.dump(body)
      @http.delete(@urls.ssh_keys_url, body: body, headers: headers)
    end

    def delete_ssh_keys
      ssh_keys = find_ssh_keys
      ssh_keys.each do |ssh_key|
        fingerprint = ssh_key[:fingerprint]
        hostname = ssh_key[:hostname]
        options = hostname && { hostname: hostname }
        args = [fingerprint, options].compact
        delete_ssh_key(*args)
      end
    end

    def find_checkout_keys
      response = @http.get(@urls.checkout_keys_url, headers: headers)
      JSON.parse(response.body, symbolize_names: true)
    end

    def create_checkout_key(type)
      type_strings = {
        deploy_key: 'deploy-key',
        github_user_key: 'github-user-key'
      }
      body = JSON.dump(type: type_strings[type.to_sym] || type.to_s)
      @http.post(@urls.checkout_keys_url, body: body, headers: headers)
    end

    def delete_checkout_key(fingerprint)
      @http.delete(@urls.checkout_key_url(fingerprint), headers: headers)
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
        'Circle-Token': @api_token,
        'Content-Type': 'application/json',
        Accept: 'application/json'
      }
    end
  end
end
