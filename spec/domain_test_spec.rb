require 'spec_helper'
gem 'rackspace-clouddns'
gem 'rspec'
describe 'Domain_test' do
  it 'Crea cliente cloudDNS y dominio' do
    #creamos el cliente dns
    dns = CloudDns.new(:username => 'jogeavi914', :api_key => '9d6c2204896497a4bcec4223227e936b')
    
    dns.username
    dns.api_auth
    dns.account_id
    dns.api_key
    dns.api_base
    dns.auth_token
    doms = dns.get_domains
     
    #creamos un dominio nuevo
    #domain = dns.create_domain('rubyspecs.com', :email => 'jogeavi914@gmail.com')
    
    #obtenemos la lista de los dominios
    #domains = dns.domains
    
    #puts domains
  end
end
