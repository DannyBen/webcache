class WebCache
  class Response
    attr_accessor :error, :base_uri, :content

    def initialize(opts={})
      if opts.respond_to?(:read) && opts.respond_to?(:base_uri)
        init_with_uri opts
      elsif opts.is_a? Hash
        init_with_hash opts
      end
    end

    def to_s
      content
    end

    private

    def init_with_uri(opts)
      self.content  = opts.read
      self.base_uri = opts.base_uri
      self.error    = nil
    end

    def init_with_hash(opts)
      self.error    = opts[:error]
      self.base_uri = opts[:base_uri]
      self.content  = opts[:content]
    end
  end
end
