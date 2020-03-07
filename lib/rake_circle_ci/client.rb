require 'json'
require 'excon'

module RakeCircleCI
  class Client
    def initialize(opts)
      @base_url = opts[:base_url]
      @api_token = opts[:api_token]
      @project_slug = opts[:project_slug]
    end

    def create_env_var(name, value)
      body = JSON.dump(name: name, value: value)
      assert_successful(
          Excon.post(env_vars_url, body: body, headers: headers))
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
  end
end