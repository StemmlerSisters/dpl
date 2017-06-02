require 'spec_helper'
require 'dpl/provider/heroku'
require 'faraday'

describe DPL::Provider::Heroku do
  subject :provider do
    described_class.new(DummyContext.new, :app => 'example', :key_name => 'key', :api_key => "foo", :strategy => "git-ssh")
  end

  let(:api_key) {'foo'}
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:faraday) {
    Faraday.new do |builder|
      builder.adapter :test, stubs do |stub|
        stub.get("/account") {|env| [200, response_headers, account_response_body]}
        stub.get("/apps/example") {|env| [200, response_headers, app_response_body]}
        stub.post("/apps/example/builds") {|env| [201, response_headers, builds_response_body]}
        stub.get("/apps/example/builds/01234567-89ab-cdef-0123-456789abcdef/result") {|env| [200, response_headers, build_result_response_body]}
        stub.post("/sources") {|env| [201, response_headers, source_response_body] }
        stub.post("/apps/example/dynos") {|env| [201, response_headers, dynos_create_response_body]}
        stub.delete("/apps/example/dynos") {|env| [202, response_headers, '{}'] }
      end
    end
  }

  let(:response_headers) {
    {'Content-Type' => 'application/json'}
  }

  let(:app_response_body) {
'{
  "acm": false,
  "archived_at": "2012-01-01T12:00:00Z",
  "buildpack_provided_description": "Ruby/Rack",
  "build_stack": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "cedar-14"
  },
  "created_at": "2012-01-01T12:00:00Z",
  "git_url": "https://git.heroku.com/example.git",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "maintenance": false,
  "name": "example",
  "owner": {
    "email": "username@example.com",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "organization": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "example"
  },
  "team": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "example"
  },
  "region": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "us"
  },
  "released_at": "2012-01-01T12:00:00Z",
  "repo_size": 0,
  "slug_size": 0,
  "space": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "nasa",
    "shield": true
  },
  "stack": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "cedar-14"
  },
  "updated_at": "2012-01-01T12:00:00Z",
  "web_url": "https://example.herokuapp.com/"
}'
  }

  let(:account_response_body) {
'{
  "allow_tracking": true,
  "beta": false,
  "created_at": "2012-01-01T12:00:00Z",
  "email": "username@example.com",
  "federated": false,
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "identity_provider": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "organization": {
      "name": "example"
    }
  },
  "last_login": "2012-01-01T12:00:00Z",
  "name": "Tina Edmonds",
  "sms_number": "+1 ***-***-1234",
  "suspended_at": "2012-01-01T12:00:00Z",
  "delinquent_at": "2012-01-01T12:00:00Z",
  "two_factor_authentication": false,
  "updated_at": "2012-01-01T12:00:00Z",
  "verified": false,
  "default_organization": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "example"
  }
}'
  }

  let(:builds_response_body) {
'{
  "app": {
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "buildpacks": [
    {
      "url": "https://github.com/heroku/heroku-buildpack-ruby"
    }
  ],
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "output_stream_url": "https://build-output.heroku.com/streams/01234567-89ab-cdef-0123-456789abcdef",
  "source_blob": {
    "checksum": "SHA256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
    "url": "https://example.com/source.tgz?token=xyz",
    "version": "v1.3.0"
  },
  "release": {
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "slug": {
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "status": "succeeded",
  "updated_at": "2012-01-01T12:00:00Z",
  "user": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "email": "username@example.com"
  }
}'
  }

  let(:source_response_body) {
'{
  "source_blob": {
    "get_url": "https://api.heroku.com/sources/1234.tgz",
    "put_url": "https://api.heroku.com/sources/1234.tgz"
  }
}'
  }

  let(:dynos_create_response_body) {
'{
  "attach_url": "rendezvous://rendezvous.runtime.heroku.com:5000/rendezvous",
  "command": "bash",
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "name": "run.1",
  "release": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "version": 11
  },
  "app": {
    "name": "example",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "size": "standard-1X",
  "state": "up",
  "type": "run",
  "updated_at": "2012-01-01T12:00:00Z"
}'
  }
  let(:build_result_response_body) {
'{
    "build": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "status": "succeeded",
    "output_stream_url": "https://build-output.heroku.com/streams/01234567-89ab-cdef-0123-456789abcdef"
  },
  "exit_code": 0,
  "lines": [
    {
      "line": "-----> Ruby app detected\n",
      "stream": "STDOUT"
    }
  ]
}'
  }

  let(:build_result_response_body_failure) {
'{
    "build": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "status": "failed",
    "output_stream_url": "https://build-output.heroku.com/streams/01234567-89ab-cdef-0123-456789abcdef"
  },
  "exit_code": 1,
  "lines": [
    {
      "line": "-----> Ruby app detected\n",
      "stream": "STDOUT"
    }
  ]
}'
  }

  let(:build_result_response_body_in_progress) {
'{
    "build": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "status": "failed",
    "output_stream_url": "https://build-output.heroku.com/streams/01234567-89ab-cdef-0123-456789abcdef"
  },
  "lines": [
    {
      "line": "-----> Ruby app detected\n",
      "stream": "STDOUT"
    }
  ]
}'
  }

  let(:expected_headers) do
    { "Authorization" => "Bearer #{api_key}", "Accept" => "application/vnd.heroku+json; version=3" }
  end

  let(:api_url) { 'https://api.heroku.com' }


  describe "#api" do
    it 'accepts an api key' do
      expect(provider).to receive(:faraday).at_least(:once).and_return(faraday)
      provider.check_auth
    end
  end

  context "with faraday" do
    before :each do
      expect(provider).to receive(:faraday).at_least(:once).and_return(faraday)
    end

    describe "#check_auth" do
      example do
        expect(provider).to receive(:log).with("authenticated as username@example.com")
        provider.check_auth
      end
    end

    describe "#check_app" do
      example do
        expect(provider).to receive(:log).at_least(1).times.with(/example/)
        provider.check_app
      end
    end

    describe "#run" do
      example do
        expect(Rendezvous).to receive(:start).with(:url => "rendezvous://rendezvous.runtime.heroku.com:5000/rendezvous")
        provider.run("that command")
      end
    end

    describe "#restart" do
      example do
        provider.restart
      end
    end
  end

  context "without faraday" do
    describe "#push_app" do
      example do
        provider.options[:git] = "git://something"
        expect(provider.context).to receive(:shell).with("git fetch origin $TRAVIS_BRANCH --unshallow")
        expect(provider.context).to receive(:shell).with("git push git://something HEAD:refs/heads/master -f")
        provider.push_app
        expect(provider.context.env['GIT_HTTP_USER_AGENT']).to include("dpl/#{DPL::VERSION}")
      end
    end
  end
end
