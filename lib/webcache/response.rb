class WebCache
  class Response
    attr_accessor :error, :base_uri, :content, :code

    def initialize(opts = {})
      case opts
      when HTTP::Response then init_with_http_response opts
      when Hash           then init_with_hash opts
      end
    end

    def to_s
      content
    end

    def success?
      !error
    end

  private

    def init_with_http_response(response)
      @base_uri = response.uri
      @code = response.code
      if response.status.success?
        @content  = response.to_s
        @error    = nil
      else
        @content  = response.status.to_s
        @error    = response.status.to_s
      end
    end

    def init_with_hash(opts)
      @error    = opts[:error]
      @base_uri = opts[:base_uri]
      @content  = opts[:content]
      @code     = opts[:code]
    end
  end
end
