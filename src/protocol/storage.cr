# Storage module dependencies
require "./browser"
require "./network"

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module Storage
    # ----------------------------------------
    # Storage Section: types
    # ----------------------------------------

    alias SerializedStorageKey = String

    # Enum of possible storage types.
    enum StorageType
      Appcache       # appcache
      Cookies        # cookies
      FileSystems    # file_systems
      Indexeddb      # indexeddb
      LocalStorage   # local_storage
      ShaderCache    # shader_cache
      Websql         # websql
      ServiceWorkers # service_workers
      CacheStorage   # cache_storage
      InterestGroups # interest_groups
      SharedStorage  # shared_storage
      All            # all
      Other          # other
    end

    # Usage for a storage type.
    struct UsageForType
      include JSON::Serializable
      @[JSON::Field(key: "storageType")]
      # Name of storage type.
      getter storage_type : StorageType
      # Storage usage (bytes).
      getter usage : Number::Primitive
    end

    # Pair of issuer origin and number of available (signed, but not used) Trust
    # Tokens from that issuer.
    struct TrustTokens
      include JSON::Serializable
      @[JSON::Field(key: "issuerOrigin")]
      getter issuer_origin : String
      getter count : Number::Primitive
    end

    # Enum of interest group access types.
    enum InterestGroupAccessType
      Join   # join
      Leave  # leave
      Update # update
      Bid    # bid
      Win    # win
    end

    # Ad advertising element inside an interest group.
    struct InterestGroupAd
      include JSON::Serializable
      @[JSON::Field(key: "renderUrl")]
      getter render_url : String
      getter metadata : String?
    end

    # The full details of an interest group.
    struct InterestGroupDetails
      include JSON::Serializable
      @[JSON::Field(key: "ownerOrigin")]
      getter owner_origin : String
      getter name : String
      @[JSON::Field(key: "expirationTime")]
      getter expiration_time : Network::TimeSinceEpoch
      @[JSON::Field(key: "joiningOrigin")]
      getter joining_origin : String
      @[JSON::Field(key: "biddingUrl")]
      getter bidding_url : String?
      @[JSON::Field(key: "biddingWasmHelperUrl")]
      getter bidding_wasm_helper_url : String?
      @[JSON::Field(key: "updateUrl")]
      getter update_url : String?
      @[JSON::Field(key: "trustedBiddingSignalsUrl")]
      getter trusted_bidding_signals_url : String?
      @[JSON::Field(key: "trustedBiddingSignalsKeys")]
      getter trusted_bidding_signals_keys : Array(String)
      @[JSON::Field(key: "userBiddingSignals")]
      getter user_bidding_signals : String?
      getter ads : Array(InterestGroupAd)
      @[JSON::Field(key: "adComponents")]
      getter ad_components : Array(InterestGroupAd)
    end

    # Struct for a single key-value pair in an origin's shared storage.
    struct SharedStorageEntry
      include JSON::Serializable
      getter key : String
      getter value : String
    end

    # Details for an origin's shared storage.
    struct SharedStorageMetadata
      include JSON::Serializable
      @[JSON::Field(key: "creationTime")]
      getter creation_time : Network::TimeSinceEpoch
      getter length : Int::Primitive
      @[JSON::Field(key: "remainingBudget")]
      getter remaining_budget : Number::Primitive
    end

    # ----------------------------------------
    # Storage Section: commands
    # ----------------------------------------

    # Returns a storage key given a frame id.
    struct GetStorageKeyForFrame
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "storageKey")]
      getter storage_key : SerializedStorageKey
    end

    # Clears storage for origin.
    struct ClearDataForOrigin
      include Protocol::Command
      include JSON::Serializable
    end

    # Clears storage for storage key.
    struct ClearDataForStorageKey
      include Protocol::Command
      include JSON::Serializable
    end

    # Returns all browser cookies.
    struct GetCookies
      include Protocol::Command
      include JSON::Serializable
      # Array of cookie objects.
      getter cookies : Array(Network::Cookie)
    end

    # Sets given cookies.
    struct SetCookies
      include Protocol::Command
      include JSON::Serializable
    end

    # Clears cookies.
    struct ClearCookies
      include Protocol::Command
      include JSON::Serializable
    end

    # Returns usage and quota in bytes.
    struct GetUsageAndQuota
      include Protocol::Command
      include JSON::Serializable
      # Storage usage (bytes).
      getter usage : Number::Primitive
      # Storage quota (bytes).
      getter quota : Number::Primitive
      @[JSON::Field(key: "overrideActive")]
      # Whether or not the origin has an active storage quota override
      getter override_active : Bool
      @[JSON::Field(key: "usageBreakdown")]
      # Storage usage per type (bytes).
      getter usage_breakdown : Array(UsageForType)
    end

    # Override quota for the specified origin
    struct OverrideQuotaForOrigin
      include Protocol::Command
      include JSON::Serializable
    end

    # Registers origin to be notified when an update occurs to its cache storage list.
    struct TrackCacheStorageForOrigin
      include Protocol::Command
      include JSON::Serializable
    end

    # Registers origin to be notified when an update occurs to its IndexedDB.
    struct TrackIndexedDBForOrigin
      include Protocol::Command
      include JSON::Serializable
    end

    # Registers storage key to be notified when an update occurs to its IndexedDB.
    struct TrackIndexedDBForStorageKey
      include Protocol::Command
      include JSON::Serializable
    end

    # Unregisters origin from receiving notifications for cache storage.
    struct UntrackCacheStorageForOrigin
      include Protocol::Command
      include JSON::Serializable
    end

    # Unregisters origin from receiving notifications for IndexedDB.
    struct UntrackIndexedDBForOrigin
      include Protocol::Command
      include JSON::Serializable
    end

    # Unregisters storage key from receiving notifications for IndexedDB.
    struct UntrackIndexedDBForStorageKey
      include Protocol::Command
      include JSON::Serializable
    end

    # Returns the number of stored Trust Tokens per issuer for the
    # current browsing context.
    struct GetTrustTokens
      include Protocol::Command
      include JSON::Serializable
      getter tokens : Array(TrustTokens)
    end

    # Removes all Trust Tokens issued by the provided issuerOrigin.
    # Leaves other stored data, including the issuer's Redemption Records, intact.
    struct ClearTrustTokens
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "didDeleteTokens")]
      # True if any tokens were deleted, false otherwise.
      getter did_delete_tokens : Bool
    end

    # Gets details for a named interest group.
    struct GetInterestGroupDetails
      include Protocol::Command
      include JSON::Serializable
      getter details : InterestGroupDetails
    end

    # Enables/Disables issuing of interestGroupAccessed events.
    struct SetInterestGroupTracking
      include Protocol::Command
      include JSON::Serializable
    end

    # Gets metadata for an origin's shared storage.
    struct GetSharedStorageMetadata
      include Protocol::Command
      include JSON::Serializable
      getter metadata : SharedStorageMetadata
    end

    # Gets the entries in an given origin's shared storage.
    struct GetSharedStorageEntries
      include Protocol::Command
      include JSON::Serializable
      getter entries : Array(SharedStorageEntry)
    end

    # ----------------------------------------
    # Storage Section: events
    # ----------------------------------------

    # A cache's contents have been modified.
    struct CacheStorageContentUpdated
      include JSON::Serializable
      include Protocol::Event
      # Origin to update.
      getter origin : String
      @[JSON::Field(key: "cacheName")]
      # Name of cache in origin.
      getter cache_name : String
    end

    # A cache has been added/deleted.
    struct CacheStorageListUpdated
      include JSON::Serializable
      include Protocol::Event
      # Origin to update.
      getter origin : String
    end

    # The origin's IndexedDB object store has been modified.
    struct IndexedDBContentUpdated
      include JSON::Serializable
      include Protocol::Event
      # Origin to update.
      getter origin : String
      @[JSON::Field(key: "storageKey")]
      # Storage key to update.
      getter storage_key : String
      @[JSON::Field(key: "databaseName")]
      # Database to update.
      getter database_name : String
      @[JSON::Field(key: "objectStoreName")]
      # ObjectStore to update.
      getter object_store_name : String
    end

    # The origin's IndexedDB database list has been modified.
    struct IndexedDBListUpdated
      include JSON::Serializable
      include Protocol::Event
      # Origin to update.
      getter origin : String
      @[JSON::Field(key: "storageKey")]
      # Storage key to update.
      getter storage_key : String
    end

    # One of the interest groups was accessed by the associated page.
    struct InterestGroupAccessed
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "accessTime")]
      getter access_time : Network::TimeSinceEpoch
      getter type : InterestGroupAccessType
      @[JSON::Field(key: "ownerOrigin")]
      getter owner_origin : String
      getter name : String
    end
  end
end
