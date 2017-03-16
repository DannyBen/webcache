class WebCache
  class Response
    attr_accessor :error, :base_uri, :content

    def initialize(opts={})
      if opts.respond_to?(:read) && opts.respond_to?(:base_uri)
        self.content  = opts.read
        self.base_uri = opts.base_uri
        self.error    = nil
      elsif opts.is_a? Hash
        self.error    = opts[:error]    if opts[:error]
        self.base_uri = opts[:base_uri] if opts[:base_uri]
        self.content  = opts[:content]  if opts[:content]
      end
    end

    def to_s
      content
    end
  end
end
