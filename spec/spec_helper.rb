$:.unshift File.expand_path("../..", __FILE__)

require 'clouddns'
require 'webmock'
require 'webmock/rspec'
require 'simplecov'

SimpleCov.start do
  add_group 'CloudDns', 'lib/clouddns'
end

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end

def api_url(path='')
  "#{CloudDns::API_BASE[:us]}/v1.0/12345#{path}"
end

def auth_url
  "#{CloudDns::API_AUTH[:us]}/v1.0"
end

def stub_headers
  {
    'Accept'       => 'application/json',
    'X-Auth-Token' => 'AUTH_TOKEN'
  }
end

def stub_get(path, params, fixture_name)
  stub_options = {:headers => stub_headers}
  stub_options.merge!(:query => params) unless (params || {}).empty?
  
  stub_request(:get, api_url(path)).with(stub_options).
    to_return(
      :status => 200,
      :body => fixture(fixture_name),
      :headers => {}
    )
end

def stub_failure(method, path, params, status)
  stub_options = {:headers => stub_headers}
  stub_options.merge!(:query => params) unless (params || {}).empty?
  
  stub_request(method, api_url(path)).with(stub_options).
    to_return(:status => status)
end

def stub_authentication(token='AUTH_TOKEN', account_id='12345')
  stub_request(:get, auth_url).
    with(:headers => {
      'Accept'      => 'application/json',
      'X-Auth-Key'  => 'bar',
      'X-Auth-User' => 'foo'
    }).
    to_return(
      :status => 204,
      :body => "",
      :headers => {
        'X-Auth-Token' => "#{token}",
        'X-Server-Management-URL' => "https://servers.api.rackspacecloud.com/v1.0/#{account_id}"
      }
    )
end
