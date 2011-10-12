require 'spec_helper'

describe CloudDns::Client do
  it 'raises Argument error if no credentials were provided' do
    proc { CloudDns.new }.
      should raise_error ArgumentError, "Client :username required!"
      
    proc { CloudDns.new(:username => 'foo') }.
      should raise_error ArgumentError, "Client :api_key required!"
      
    proc { CloudDns.new(:username => 'foo', :api_key => 'bar') }.
      should_not raise_error
  end
  
  context 'on authentication' do 
    it 'raises CloudDns::Unauthorized exception for invalid credentials' do
      stub_request(:get, auth_url).
         with(:headers => {'Accept'=>'application/json', 'X-Auth-Key'=>'key', 'X-Auth-User'=>'invalid'}).
         to_return(:status => 401, :body => "", :headers => {})
      
      proc {
        CloudDns.new(:username => 'invalid', :api_key => 'key').authenticate
      }.should raise_error CloudDns::Unauthorized
    end
    
    it 'sets authentication token for valid credentials' do
      stub_authentication
      client = CloudDns.new(:username => 'foo', :api_key => 'bar')
      client.auth_token.nil?.should == true
      client.authenticate
      client.auth_token.nil?.should == false
      client.auth_token.should == 'AUTH_TOKEN'
      client.account_id.should == 12345
    end
  end
  
  context 'with authentication' do
    before :each do
      @client = CloudDns::Client.new(:username => 'foo', :api_key => 'bar')
      stub_authentication
    end
    
    it 'returns a list of domains' do
      stub_get('/domains', {:showDetails => 'true', :limit => '10', :offset => '0'}, 'domains.json')
      stub_get('/domains/1/records', {:showDetails => 'true'}, 'records.json')
      stub_get('/domains/2/records', {:showDetails => 'true'}, 'records.json')
      domains = @client.domains    
      domains.should be_an Array
      domains.size.should == 2
      
      d = domains.first
      d.should be_an CloudDns::Domain
      d.id.should == 1
      d.name.should == 'foobar.com'
      d.client.should == @client
    end
  
    it 'returns a single domain' do
      stub_get('/domains/1?showDetails=true', {'showRecords' => 'true', 'showSubdomains' => 'true'}, 'domain.json')
      
      domain = @client.domain(1)
      domain.should be_an CloudDns::Domain
      domain.new?.should == false
      domain.id.should == 1
      domain.name.should == 'foobar.com'
      domain.client.should == @client
    end
    
    it 'raises CloudDns::NotFound if requested domain does not exist' do
      stub_failure(:get, '/domains/2?showDetails=true', {}, 404)
      proc { @client.domain(2, {}) }.should raise_error CloudDns::NotFound
    end
  end
end
