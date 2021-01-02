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

  context '#create_checkout_key' do
    it 'creates a checkout key on the project' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      base_url = 'https://circleci.com/api'
      checkout_keys_url =
          'https://circleci.com/api/v1.1/project/github/org/repo/checkout-key'

      client = RakeCircleCI::Client.new(
          project_slug: project_slug,
          api_token: api_token,
          base_url: base_url)

      expected_body = JSON.dump(type: 'deploy-key')
      expected_headers = {
          'Circle-Token': api_token,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
      }

      public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQClOS845nhgELaCpJ6b" +
          "/MEefnIVb49+vbL2hEQAufmqlibpm8cfBFqcQZdG3BEbVKofpRBGVzuma3XiR8+nc" +
          "YAlPPKdrFU/petXzJlEwm3TjcwpkvIydDH1gBW7uf/IaRvnmHrAQ3916gGY36ebVo" +
          "48ZPjSBdBos9VaG7EU9KJXKJlar3u/3rDE9JHly+wM8mdT+ZLLHyk4+9UqA96fvmd" +
          "Fo8sTgVKD1Bh22VzgxiCRRYc7cRNF+e/wLrKJpjzxf7XXR5tYCElBXa4Ru+a5E4jU" +
          "IX5ro6WCg7rGDUbVHGITjn89OSLRmkNYUm+HpxA05NE+C5THeSYs+HvSYY/COqUj+" +
          "nbj4+FPU5L81BXx+QVI1XUUFd5itOpoZOMsKC6aEw6IrMYRRrygu9NZaxgtdE1V4D" +
          "oWgxr9OdON6HseJQG2FwyHTQntdtJzUhBhuyrBc0FQV+5mKrCIC5qmQL4l01rPir2" +
          "a1WhyRcDx2I75PRYDyzFUElaXFEqqFr39kLQjFcQSXcTLEZsotvc+qHfBh4BvaW61" +
          "R8GPylijzXpcS+7ezcK9fGmtmgyiuTqre7MLSjEARvzO85k28+J35OHECoQxyBWnK" +
          "9ePAYQYBpbU7mj6GojCiv+8rpw3hX+A5sqLEgwwFGEWJLyZaNKNifjQWjeRxD/jeg" +
          "s8dOSwQIoFB6v7FQ=="

      response = double('create checkout key response',
          status: 201,
          body: JSON.dump(
              public_key: public_key,
              type: "deploy-key",
              fingerprint: "d6:1b:2e:59:ca:11:a1:b0:23:83:93:ef:93:d8:a4:50",
              login: nil,
              preferred: true,
              time: "2021-01-01T23:29:01.432Z"
          ))
      expect(Excon)
          .to(receive(:post)
              .with(checkout_keys_url,
                  body: expected_body,
                  headers: expected_headers)
              .and_return(response))

      client.create_checkout_key(:deploy_key)
    end

    it 'raises an exception on failure' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = "https://circleci.com"
      base_path = "/api"
      base_url = "#{host}#{base_path}"

      checkout_keys_path =
          "#{base_path}/v1.1/project/github/org/repo/checkout-key"
      checkout_keys_url = "#{host}#{checkout_keys_path}"

      client = RakeCircleCI::Client.new(
          project_slug: project_slug,
          api_token: api_token,
          base_url: base_url)

      expected_body = JSON.dump(
          type: 'deploy-key')
      expected_headers = {
          'Circle-Token': api_token,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
      }

      response = double('create checkout key response',
          status: 400,
          data: {
              host: host,
              path: checkout_keys_path,
              reason_phrase: 'Bad Request'
          })
      allow(Excon)
          .to(receive(:post)
              .with(checkout_keys_url,
                  body: expected_body,
                  headers: expected_headers)
              .and_return(response))

      expect {
        client.create_checkout_key(:deploy_key)
      }.to(raise_error(RuntimeError,
          "Unsuccessful request: #{checkout_keys_url} 400 Bad Request"))
    end
  end

  context '#delete_checkout_key' do
    it 'deletes an checkout key from the project' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      base_url = 'https://circleci.com/api'

      fingerprint = "ed:2d:db:67:27:f2:22:51:33:ac:6f:70:35:0a:e7:37"

      checkout_key_url =
          "#{base_url}/v1.1/project/github/org/repo/checkout-key/#{fingerprint}"

      client = RakeCircleCI::Client.new(
          project_slug: project_slug,
          api_token: api_token,
          base_url: base_url)

      expected_headers = {
          'Circle-Token': api_token,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
      }

      response = double('delete checkout key response',
          status: 200,
          body: JSON.dump({
              message: "ok"
          }))
      expect(Excon)
          .to(receive(:delete)
              .with(checkout_key_url,
                  headers: expected_headers)
              .and_return(response))

      client.delete_checkout_key(fingerprint)
    end

    it 'raises an exception on failure' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = "https://circleci.com"
      base_path = "/api"
      base_url = "#{host}#{base_path}"

      fingerprint = "ed:2d:db:67:27:f2:22:51:33:ac:6f:70:35:0a:e7:37"

      checkout_key_path =
          "#{base_path}/v1.1/project/github/org/repo/checkout-key/" +
              "#{fingerprint}"
      checkout_key_url = "#{host}#{checkout_key_path}"

      client = RakeCircleCI::Client.new(
          project_slug: project_slug,
          api_token: api_token,
          base_url: base_url)

      expected_headers = {
          'Circle-Token': api_token,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
      }

      response = double('delete checkout key response',
          status: 400,
          data: {
              host: host,
              path: checkout_key_path,
              reason_phrase: 'Bad Request'
          })
      allow(Excon)
          .to(receive(:delete)
              .with(checkout_key_url,
                  headers: expected_headers)
              .and_return(response))

      expect {
        client.delete_checkout_key(fingerprint)
      }.to(raise_error(RuntimeError,
          "Unsuccessful request: #{checkout_key_url} 400 Bad Request"))
    end
  end

  context '#find_checkout_keys' do
    it 'finds all checkout keys on the project' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      base_url = 'https://circleci.com/api'

      fingerprint_1 = "ed:2d:db:67:27:f2:22:51:33:ac:6f:70:35:0a:e7:37"
      fingerprint_2 = "80:d9:83:0e:72:fc:a9:8a:35:78:7a:dd:4b:58:48:29"

      checkout_keys_url =
          "#{base_url}/v1.1/project/github/org/repo/checkout-key"
      checkout_key_1_url = "#{checkout_keys_url}/#{fingerprint_1}"
      checkout_key_2_url = "#{checkout_keys_url}/#{fingerprint_2}"

      client = RakeCircleCI::Client.new(
          project_slug: project_slug,
          api_token: api_token,
          base_url: base_url)

      expected_headers = {
          'Circle-Token': api_token,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
      }

      public_key_1 =
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCqV6EPxZkI4YMj1PTAK5uA" +
              "QJ7lfoBvaiynHUPYoJxiIGclOamg93W5j+EQUsQUQ9wjcYkJJTcf4KvksW573m1Nr" +
              "NWPQCo7Y2/ysXoMs7y1JGXiB/AHLDX1KQ8jrRna+2w+nVLMXUXq2DqNdpKXG8jTcJ" +
              "9gPEW1/zJ5rMt950auIcEywT0QFrl2C2EYosCcC57LLbNa6qwvVJ3f09WPbWL6dhM" +
              "HLa7mB/ZeNv8EZnfY38dh65jnEUPLjJPRUs523JhWiLli930cdOp1xqDdP0Y/dgeN" +
              "F7hNxjeL1EMVy5gvWsTv1Oewd4215bIh2nhnAxr57wRbOXrm+Uj/FHsQZTWUKg2z0" +
              "uLPj7oZADb/2oTudndt2QIVjdlvHRQL4sURsTFyDMRZKXDBeiVBNJ9ybGrJgLDVw8" +
              "OISjhTh9htty4ceKQQR1whomzu2y3IrWvPxkS5M0ZSofhNQMlEOv0eAZxwdcOYYMv" +
              "e1kWknJksdF09WZqZSCOinL4W4N+gcw2nxEgD4aZcBwZD6/Fq/PKcXMuyZ5IMlSh8" +
              "1OY1vXCeGb6fNLRpF6geKEXju1GF0R0bC5LMQY6yuYoQq/6kODaj7GwJUDTND638V" +
              "4iL77Xo5ACZDhf3A4MOnpCbHdqvPQOYFx+FFUjpYBRVuPwhB1aIqEFedq8Na4VbsA" +
              "+qInvFJZ4tcQ=="
      public_key_2 =
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDNaNp0GS0Yh9Otbt" +
              "c5bwOp9t0eKTIYHFdSpYaPCDHe9RnclDqLpgL7mXMci2Zq/8g9NeEcEdDiGpVKOot" +
              "ucPDMeDvRD1nTI4HWv7wiE1t+9GqReb9kvoGS3AU7AFMrTin7UwjS4IznvdYiCLSA" +
              "Jbbbil5GZuNTeIFkF7sDIcwnnzaACD3Rfh8Jn94useo8230Zg1MK6c5k9yP24j2AL" +
              "rIfLiDGr0zp1UhNT1Ccm6/srkuk6GMvbmkmOZavFhJttd1NkG95dDBWS/uDcy3c7/" +
              "uWsOB2vhARt6P1ecRxq7w4Hamun+a/LLjmXh2OOkEt/Kd0ONnpMoYekHIlJr9pLtB" +
              "33+K9zrTfXC00KgO5KbjhkjMx+Jx4kB9vDd/6Kk4xl0MVhGykhkyxkvG5ihNSA0EQ" +
              "VBQO7m9RmIN1O8Hk3GDpCxdUD0u2/i0fJf2qhpbLd7Gl+qQqtRJSCWYXvuUb2Te/V" +
              "oS9ytfURYpYw+iwVEOYqqSjjzawj4E8/3KGW/N30Geev5gq1fYoZcIzW7jRdDFgE9" +
              "sK0ijjU8GS5JoZb/95fzQUXRnjRrDo4x8U9XIJbmnbArtvJv45fUXlppV1jicMpQp" +
              "XxPkimQ1XmAEa44ATEkqaISQs4jAelJHPwyYOveSCiCXSSMIbGHCDFKX0kPexmRuH" +
              "U6AdyxAkKoNGixYoCw=="

      time_1 = "2020-12-31T19:52:45.088Z"
      time_2 = "2020-12-30T21:12:24.565Z"

      response = double('get checkout keys response',
          status: 200,
          body: JSON.dump([
              {
                  public_key: public_key_1,
                  type: "github-user-key",
                  fingerprint: fingerprint_1,
                  login: "tobyclemson",
                  preferred: true,
                  time: time_1
              },
              {
                  public_key: public_key_2,
                  type: "deploy-key",
                  fingerprint: fingerprint_2,
                  login: nil,
                  preferred: false,
                  time: time_2
              }
          ]))
      expect(Excon)
          .to(receive(:get)
              .with(checkout_keys_url,
                  headers: expected_headers)
              .and_return(response))

      checkout_keys = client.find_checkout_keys

      expect(checkout_keys)
          .to(eq([
              {
                  public_key: public_key_1,
                  type: "github-user-key",
                  fingerprint: fingerprint_1,
                  login: "tobyclemson",
                  preferred: true,
                  time: time_1
              },
              {
                  public_key: public_key_2,
                  type: "deploy-key",
                  fingerprint: fingerprint_2,
                  login: nil,
                  preferred: false,
                  time: time_2
              }
          ]))
    end

    it 'raises an exception on failure' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = "https://circleci.com"
      base_path = "/api"
      base_url = "#{host}#{base_path}"

      checkout_keys_path =
          "#{base_path}/v1.1/project/github/org/repo/checkout-key"
      checkout_keys_url =
          "#{host}#{checkout_keys_path}"

      client = RakeCircleCI::Client.new(
          project_slug: project_slug,
          api_token: api_token,
          base_url: base_url)

      expected_headers = {
          'Circle-Token': api_token,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
      }

      response = double('get checkout keys response',
          status: 400,
          data: {
              host: host,
              path: checkout_keys_path,
              reason_phrase: 'Bad Request'
          })
      allow(Excon)
          .to(receive(:get)
              .with(checkout_keys_url,
                  headers: expected_headers)
              .and_return(response))

      expect {
        client.find_checkout_keys
      }.to(raise_error(RuntimeError,
          "Unsuccessful request: #{host}#{checkout_keys_path} 400 Bad Request"))
    end
  end

  context '#delete_checkout_keys' do
    it 'deletes each checkout key on the project' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      base_url = 'https://circleci.com/api'

      fingerprint_1 = "ed:2d:db:67:27:f2:22:51:33:ac:6f:70:35:0a:e7:37"
      fingerprint_2 = "80:d9:83:0e:72:fc:a9:8a:35:78:7a:dd:4b:58:48:29"

      checkout_keys_url =
          "#{base_url}/v1.1/project/github/org/repo/checkout-key"
      checkout_key_1_url = "#{checkout_keys_url}/#{fingerprint_1}"
      checkout_key_2_url = "#{checkout_keys_url}/#{fingerprint_2}"

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
              .with(checkout_keys_url,
                  headers: expected_headers)
              .and_return(
                  double('list checkout keys response',
                      status: 200,
                      body: JSON.dump([
                          {
                              public_key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQA" +
                                  "BAAACAQCqV6EPxZkI4YMj1PTAK5uAQJ7lfoBvaiyn" +
                                  "HUPYoJxiIGclOamg93W5j+EQUsQUQ9wjcYkJJTcf4" +
                                  "KvksW573m1NrNWPQCo7Y2/ysXoMs7y1JGXiB/AHLD" +
                                  "X1KQ8jrRna+2w+nVLMXUXq2DqNdpKXG8jTcJ9gPEW" +
                                  "1/zJ5rMt950auIcEywT0QFrl2C2EYosCcC57LLbNa" +
                                  "6qwvVJ3f09WPbWL6dhMHLa7mB/ZeNv8EZnfY38dh6" +
                                  "5jnEUPLjJPRUs523JhWiLli930cdOp1xqDdP0Y/dg" +
                                  "eNF7hNxjeL1EMVy5gvWsTv1Oewd4215bIh2nhnAxr" +
                                  "57wRbOXrm+Uj/FHsQZTWUKg2z0uLPj7oZADb/2oTu" +
                                  "dndt2QIVjdlvHRQL4sURsTFyDMRZKXDBeiVBNJ9yb" +
                                  "GrJgLDVw8OISjhTh9htty4ceKQQR1whomzu2y3IrW" +
                                  "vPxkS5M0ZSofhNQMlEOv0eAZxwdcOYYMve1kWknJk" +
                                  "sdF09WZqZSCOinL4W4N+gcw2nxEgD4aZcBwZD6/Fq" +
                                  "/PKcXMuyZ5IMlSh81OY1vXCeGb6fNLRpF6geKEXju" +
                                  "1GF0R0bC5LMQY6yuYoQq/6kODaj7GwJUDTND638V4" +
                                  "iL77Xo5ACZDhf3A4MOnpCbHdqvPQOYFx+FFUjpYBR" +
                                  "VuPwhB1aIqEFedq8Na4VbsA+qInvFJZ4tcQ==",
                              type: "github-user-key",
                              fingerprint: fingerprint_1,
                              login: "tobyclemson",
                              preferred: true,
                              time: "2020-12-31T19:52:45.088Z"
                          },
                          {
                              public_key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQAB" +
                                  "AAACAQDNaNp0GS0Yh9Otbtc5bwOp9t0eKTIYHFdS" +
                                  "pYaPCDHe9RnclDqLpgL7mXMci2Zq/8g9NeEcEdDi" +
                                  "GpVKOotucPDMeDvRD1nTI4HWv7wiE1t+9GqReb9k" +
                                  "voGS3AU7AFMrTin7UwjS4IznvdYiCLSAJbbbil5G" +
                                  "ZuNTeIFkF7sDIcwnnzaACD3Rfh8Jn94useo8230Z" +
                                  "g1MK6c5k9yP24j2ALrIfLiDGr0zp1UhNT1Ccm6/s" +
                                  "rkuk6GMvbmkmOZavFhJttd1NkG95dDBWS/uDcy3c" +
                                  "7/uWsOB2vhARt6P1ecRxq7w4Hamun+a/LLjmXh2O" +
                                  "OkEt/Kd0ONnpMoYekHIlJr9pLtB33+K9zrTfXC00" +
                                  "KgO5KbjhkjMx+Jx4kB9vDd/6Kk4xl0MVhGykhkyx" +
                                  "kvG5ihNSA0EQVBQO7m9RmIN1O8Hk3GDpCxdUD0u2" +
                                  "/i0fJf2qhpbLd7Gl+qQqtRJSCWYXvuUb2Te/VoS9" +
                                  "ytfURYpYw+iwVEOYqqSjjzawj4E8/3KGW/N30Gee" +
                                  "v5gq1fYoZcIzW7jRdDFgE9sK0ijjU8GS5JoZb/95" +
                                  "fzQUXRnjRrDo4x8U9XIJbmnbArtvJv45fUXlppV1" +
                                  "jicMpQpXxPkimQ1XmAEa44ATEkqaISQs4jAelJHP" +
                                  "wyYOveSCiCXSSMIbGHCDFKX0kPexmRuHU6AdyxAk" +
                                  "KoNGixYoCw==",
                              type: "deploy-key",
                              fingerprint: fingerprint_2,
                              login: nil,
                              preferred: false,
                              time: "2020-12-30T21:12:24.565Z"
                          }
                      ]))))
      expect(Excon)
          .to(receive(:delete)
              .with(checkout_key_1_url,
                  headers: expected_headers)
              .and_return(
                  double('delete checkout key 1 response',
                      status: 200,
                      body: JSON.dump({
                          message: "ok"
                      }))))
      expect(Excon)
          .to(receive(:delete)
              .with(checkout_key_2_url,
                  headers: expected_headers)
              .and_return(
                  double('delete checkout key 2 response',
                      status: 200,
                      body: JSON.dump({
                          message: "ok"
                      }))))

      client.delete_checkout_keys
    end

    it 'raises an exception on failure' do
      project_slug = 'github/org/repo'
      api_token = 'some-token'
      host = "https://circleci.com"
      base_path = "/api"
      base_url = "#{host}#{base_path}"

      fingerprint_1 = "ed:2d:db:67:27:f2:22:51:33:ac:6f:70:35:0a:e7:37"
      fingerprint_2 = "80:d9:83:0e:72:fc:a9:8a:35:78:7a:dd:4b:58:48:29"

      checkout_keys_path =
          "#{base_path}/v1.1/project/github/org/repo/checkout-key"
      checkout_keys_url =
          "#{host}#{checkout_keys_path}"
      checkout_key_1_url = "#{checkout_keys_url}/#{fingerprint_1}"
      checkout_key_2_url = "#{checkout_keys_url}/#{fingerprint_2}"

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
              .with(checkout_keys_url,
                  headers: expected_headers)
              .and_return(
                  double('list checkout keys response',
                      status: 200,
                      body: JSON.dump([
                          {
                              public_key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQA" +
                                  "BAAACAQCqV6EPxZkI4YMj1PTAK5uAQJ7lfoBvaiyn" +
                                  "HUPYoJxiIGclOamg93W5j+EQUsQUQ9wjcYkJJTcf4" +
                                  "KvksW573m1NrNWPQCo7Y2/ysXoMs7y1JGXiB/AHLD" +
                                  "X1KQ8jrRna+2w+nVLMXUXq2DqNdpKXG8jTcJ9gPEW" +
                                  "1/zJ5rMt950auIcEywT0QFrl2C2EYosCcC57LLbNa" +
                                  "6qwvVJ3f09WPbWL6dhMHLa7mB/ZeNv8EZnfY38dh6" +
                                  "5jnEUPLjJPRUs523JhWiLli930cdOp1xqDdP0Y/dg" +
                                  "eNF7hNxjeL1EMVy5gvWsTv1Oewd4215bIh2nhnAxr" +
                                  "57wRbOXrm+Uj/FHsQZTWUKg2z0uLPj7oZADb/2oTu" +
                                  "dndt2QIVjdlvHRQL4sURsTFyDMRZKXDBeiVBNJ9yb" +
                                  "GrJgLDVw8OISjhTh9htty4ceKQQR1whomzu2y3IrW" +
                                  "vPxkS5M0ZSofhNQMlEOv0eAZxwdcOYYMve1kWknJk" +
                                  "sdF09WZqZSCOinL4W4N+gcw2nxEgD4aZcBwZD6/Fq" +
                                  "/PKcXMuyZ5IMlSh81OY1vXCeGb6fNLRpF6geKEXju" +
                                  "1GF0R0bC5LMQY6yuYoQq/6kODaj7GwJUDTND638V4" +
                                  "iL77Xo5ACZDhf3A4MOnpCbHdqvPQOYFx+FFUjpYBR" +
                                  "VuPwhB1aIqEFedq8Na4VbsA+qInvFJZ4tcQ==",
                              type: "github-user-key",
                              fingerprint: fingerprint_1,
                              login: "tobyclemson",
                              preferred: true,
                              time: "2020-12-31T19:52:45.088Z"
                          },
                          {
                              public_key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQAB" +
                                  "AAACAQDNaNp0GS0Yh9Otbtc5bwOp9t0eKTIYHFdS" +
                                  "pYaPCDHe9RnclDqLpgL7mXMci2Zq/8g9NeEcEdDi" +
                                  "GpVKOotucPDMeDvRD1nTI4HWv7wiE1t+9GqReb9k" +
                                  "voGS3AU7AFMrTin7UwjS4IznvdYiCLSAJbbbil5G" +
                                  "ZuNTeIFkF7sDIcwnnzaACD3Rfh8Jn94useo8230Z" +
                                  "g1MK6c5k9yP24j2ALrIfLiDGr0zp1UhNT1Ccm6/s" +
                                  "rkuk6GMvbmkmOZavFhJttd1NkG95dDBWS/uDcy3c" +
                                  "7/uWsOB2vhARt6P1ecRxq7w4Hamun+a/LLjmXh2O" +
                                  "OkEt/Kd0ONnpMoYekHIlJr9pLtB33+K9zrTfXC00" +
                                  "KgO5KbjhkjMx+Jx4kB9vDd/6Kk4xl0MVhGykhkyx" +
                                  "kvG5ihNSA0EQVBQO7m9RmIN1O8Hk3GDpCxdUD0u2" +
                                  "/i0fJf2qhpbLd7Gl+qQqtRJSCWYXvuUb2Te/VoS9" +
                                  "ytfURYpYw+iwVEOYqqSjjzawj4E8/3KGW/N30Gee" +
                                  "v5gq1fYoZcIzW7jRdDFgE9sK0ijjU8GS5JoZb/95" +
                                  "fzQUXRnjRrDo4x8U9XIJbmnbArtvJv45fUXlppV1" +
                                  "jicMpQpXxPkimQ1XmAEa44ATEkqaISQs4jAelJHP" +
                                  "wyYOveSCiCXSSMIbGHCDFKX0kPexmRuHU6AdyxAk" +
                                  "KoNGixYoCw==",
                              type: "deploy-key",
                              fingerprint: fingerprint_2,
                              login: nil,
                              preferred: false,
                              time: "2020-12-30T21:12:24.565Z"
                          }
                      ]))))
      expect(Excon)
          .to(receive(:delete)
              .with(checkout_key_1_url,
                  headers: expected_headers)
              .and_return(
                  double('delete checkout key 1 response',
                      status: 200,
                      body: JSON.dump({
                          message: "ok"
                      }))))
      expect(Excon)
          .to(receive(:delete)
              .with(checkout_key_2_url,
                  headers: expected_headers)
              .and_return(double('delete checkout key 2 response',
                  status: 400,
                  data: {
                      host: 'https://circleci.com',
                      path: "#{checkout_keys_path}/#{fingerprint_2}",
                      reason_phrase: 'Bad Request'
                  })))

      expect {
        client.delete_checkout_keys
      }.to(raise_error(RuntimeError,
          "Unsuccessful request: #{checkout_key_2_url} 400 Bad Request"))
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
              {
                  fingerprint: fingerprint_1,
                  hostname: hostname_1,
                  private_key: private_key_1
              },
              {
                  fingerprint: fingerprint_2,
                  private_key: private_key_2
              },
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
