# common Command module
require "./command"

module Protocol
  module CacheStorage
    # ----------------------------------------
    # CacheStorage Section: types
    # ----------------------------------------

    # Unique identifier of the Cache object.
    alias CacheId = String

    # type of HTTP response cached
    enum CachedResponseType
      Basic          # basic
      Cors           # cors
      Default        # default
      Error          # error
      OpaqueResponse # opaqueResponse
      OpaqueRedirect # opaqueRedirect
    end

    # Data entry.
    struct DataEntry
      include JSON::Serializable
      @[JSON::Field(key: "requestURL")]
      # Request URL.
      getter request_url : String
      @[JSON::Field(key: "requestMethod")]
      # Request method.
      getter request_method : String
      @[JSON::Field(key: "requestHeaders")]
      # Request headers
      getter request_headers : Array(Header)
      @[JSON::Field(key: "responseTime")]
      # Number of seconds since epoch.
      getter response_time : Number::Primitive
      @[JSON::Field(key: "responseStatus")]
      # HTTP response status code.
      getter response_status : Int::Primitive
      @[JSON::Field(key: "responseStatusText")]
      # HTTP response status text.
      getter response_status_text : String
      @[JSON::Field(key: "responseType")]
      # HTTP response type
      getter response_type : CachedResponseType
      @[JSON::Field(key: "responseHeaders")]
      # Response headers
      getter response_headers : Array(Header)
    end

    # Cache identifier.
    struct Cache
      include JSON::Serializable
      @[JSON::Field(key: "cacheId")]
      # An opaque unique id of the cache.
      getter cache_id : CacheId
      @[JSON::Field(key: "securityOrigin")]
      # Security origin of the cache.
      getter security_origin : String
      @[JSON::Field(key: "cacheName")]
      # The name of the cache.
      getter cache_name : String
    end

    struct Header
      include JSON::Serializable
      getter name : String
      getter value : String
    end

    # Cached response
    struct CachedResponse
      include JSON::Serializable
      # Entry content, base64-encoded. (Encoded as a base64 string when passed over JSON)
      getter body : String
    end

    # ----------------------------------------
    # CacheStorage Section: commands
    # ----------------------------------------

    # Deletes a cache.
    struct DeleteCache
      include Protocol::Command
      include JSON::Serializable
    end

    # Deletes a cache entry.
    struct DeleteEntry
      include Protocol::Command
      include JSON::Serializable
    end

    # Requests cache names.
    struct RequestCacheNames
      include Protocol::Command
      include JSON::Serializable
      # Caches for the security origin.
      getter caches : Array(Cache)
    end

    # Fetches cache entry.
    struct RequestCachedResponse
      include Protocol::Command
      include JSON::Serializable
      # Response read from the cache.
      getter response : CachedResponse
    end

    # Requests data from cache.
    struct RequestEntries
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "cacheDataEntries")]
      # Array of object store data entries.
      getter cache_data_entries : Array(DataEntry)
      @[JSON::Field(key: "returnCount")]
      # Count of returned entries from this storage. If pathFilter is empty, it
      # is the count of all entries from this storage.
      getter return_count : Number::Primitive
    end
  end
end
