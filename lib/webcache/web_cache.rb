class WebCache
  include CacheOperations

  class << self
    include CacheOperations
  end
end
