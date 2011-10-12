require 'digest/sha1'
require 'clouddns/client/records'

module CloudDns
  class Record < Base
    include CloudDns::Helpers
    include CloudDns::Records
    
    TYPES       = %w(A AAAA CNAME MX NS TXT SRV)
    DEFAULT_TTL = 3600
    
    attr_reader   :id          # ID from rackspace
    attr_reader   :domain_id   # Domain ID (optional, for direct calls)
    attr_reader   :created_at  # Creation timestamp
    attr_reader   :updated_at  # Last update timestamp
    
    attr_accessor :name        # Record name or title
    attr_accessor :type        # Record type (A, CNAME, MX, ...)
    attr_accessor :data        # Record contents (ip address, etc.)
    attr_accessor :ttl         # Record TTL (default: 3600)
    attr_accessor :priority    # MX record priority (optional for other types)
    attr_accessor :comment     # Optional record comment
    
    # Initialize a new CloudDns::Record instance
    #
    # client - CloudDns::Client instance
    # data   - Domain record hash
    #
    def initialize(client, data={})
      data = Hashie::Mash.new(data)
      
      @client     = client
      @id         = data.id
      @domain_id  = data.domain_id
      @name       = data.name.to_s.strip
      @type       = data.type.to_s.strip.upcase
      @data       = data.data.to_s.strip
      @ttl        = data.ttl || DEFAULT_TTL
      @priority   = data.priority
      @comment    = data.comment
      @created_at = data.created
      @updated_at = data.updated
        
      # Require client!
      unless client.kind_of?(CloudDns::Client)
        raise ArgumentError, "CloudDns::Client required!"
      end
      
      validate_record
      validate_record_data
      
      # Calculate checksum to track changes
      @original_checksum = checksum
    end
    
    def a?     ; @type == 'A'     ; end
    def aaaa?  ; @type == 'AAAA'  ; end
    def cname? ; @type == 'CNAME' ; end
    def txt?   ; @type == 'TXT'   ; end
    def ns?    ; @type == 'NS'    ; end
    def mx?    ; @type == 'MX'    ; end
    def srv?   ; @type == 'SRV'   ; end
    
    # Returns true if record does not exists
    #
    def new?
      @id.nil? && @created_at.nil?
    end
    
    # Returns true if record was changed
    #
    def changed?
      new? ? false : checksum != @original_checksum
    end
    
    # Returns a hash containing the record data for API usage
    # 
    def to_hash
      h = {'name' => @name, 'data' => @data, 'type' => @type, 'ttl' => @ttl}
      h[:id] = @id unless new?
      h[:priority] = @priority if mx?
      h
    end
    
    # Returns a formatted string with record contents
    #
    def to_s
      chunks = [@name, @ttl, 'IN', @type]
      chunks << @priority if mx?
      chunks << @data
      chunks.join(' ')
    end
    
    # Calculate record checksum based on its string representation
    #
    def checksum
      str = [@name, @ttl, @type, @data, @priority, @comment].join('')
      Digest::SHA1.hexdigest(str)
    end
    
    private
    
    # Validate record
    #
    def validate_record
      # Check if we've got all the data
      raise InvalidRecord, "Record :name required!" if @name.empty?
      raise InvalidRecord, "Record :type required!" if @type.empty?
      raise InvalidRecord, "Record :data required!" if @data.empty?
      
      # Check if its a MX record, which requires priority value
      if mx? && @priority.nil?
        raise InvalidRecord, "Record :priority required!"  
      end
      
      # Check the proper record type
      if !TYPES.include?(@type)
        raise InvalidRecord, "Invalid record type: #{@type}. Allowed types: #{TYPES.join(', ')}."
      end
    end
    
    # Validate record data based on its type
    #
    def validate_record_data
      if a?
        raise InvalidRecord, "Invalid IP: #{@data}" if !validate_ip(@data)
      end
      
      if ns?
        raise InvalidRecord, "Invalid domain: #{@data}" if !validate_domain(@data)
      end
    end
  end
end