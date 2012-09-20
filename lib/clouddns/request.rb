require 'faraday_middleware'
require 'faraday/response/raise_clouddns_error'

module CloudDns
  module Request
    
    protected
    
    def get(path, options={})
      request(:get, path, options)
    end
    
    def post(path, options={})
      request(:post, path, options)
    end
    
    def put(path, options={})
      request(:put, path, options)
    end
    
    def delete(path, options={})
      request(:delete, path, options)
    end
    
    private
    
    # Setup a faraday request
    #
    # url - Target URL
    #
    def connection(url)
      connection = Faraday.new(url) do |c|
        c.use(Faraday::Request::UrlEncoded)
        c.use(Faraday::Response::ParseJson)
        c.use(Faraday::Response::RaiseCloudDnsError)
        c.use(Faraday::Response::Logger) if CloudDns.log_requests
        c.adapter(Faraday.default_adapter)
      end
    end
     
    # Perform a HTTP request
    #
    # method - Request method, one of (:get, :post, :put, :delete)
    # path   - Request path
    # params - Custom request parameters hash (default: empty)
    # raw    - Return raw response (default: false)
    #
    # @return [Hash]
    #
    def request(method, path, params={}, raw=false)
      authenticate if auth_token.nil? || account_id.nil?
      
      headers = {
        'Accept'       => 'application/json',
        'Content-Type' => 'application/json',
        'X-Auth-Token' => auth_token
      }
      
      path = "/#{account_id}#{path}?showDetails=true" #path = "/v2.0/#{account_id}#{path}?showDetails=true"
      #removi el v2.0 porque ya esta especificado en la URL
        
      response = connection(api_base).send(method) do |request|
        request.headers.merge!(headers)
        
        case request.method
          when :delete, :get
            request.url(path, params)
          when :put, :post
            request.path = path
            request.body = MultiJson.encode(params) unless params.empty?
        end
      end
      
      raw ? response : response.body
    end
    
    # Performs an authentication request
    #
    def authentication_request
      headers = {
        'Content-Type' => 'application/json',
        'Accept'       => 'application/json',
        'X-Auth-User'  => username || '',
        'X-Auth-Key'   => api_key  || '',
      }
      
      response = connection(api_auth).send(:get) do |request|
        request.url("https://identity.api.rackspacecloud.com/v2.0/tokens") #url completa
        request.headers.merge!(headers)
      end
    end
  end
end