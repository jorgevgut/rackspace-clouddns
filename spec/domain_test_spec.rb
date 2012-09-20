require 'spec_helper.rb'
gem 'rackspace-clouddns'
gem 'rspec'
describe 'Domain_test' do
  it 'Crea cliente cloudDNS y dominio' do
    #creamos el cliente dns
    dns = CloudDns::Client.new(:username => 'jogeavi914', :api_key => '9d6c2204896497a4bcec4223227e936b', :location => :us)
    
    #creamos un dominio nuevo
    domain = dns.create_domain('rubyspecs.com', :email => 'jogeavi914@gmail.com')
    
    #obtenemos la lista de los dominios
    domains = dns.domains
  end
end
