# =============================
# Query and modify DOM storage.
# =============================

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module DOMStorage
    # ----------------------------------------
    # DOMStorage Section: types
    # ----------------------------------------

    alias SerializedStorageKey = String

    # DOM Storage identifier.
    struct StorageId
      include JSON::Serializable
      @[JSON::Field(key: "securityOrigin")]
      # Security origin for the storage.
      getter security_origin : String?
      @[JSON::Field(key: "storageKey")]
      # Represents a key by which DOM Storage keys its CachedStorageAreas
      getter storage_key : SerializedStorageKey?
      @[JSON::Field(key: "isLocalStorage")]
      # Whether the storage is local storage (not session storage).
      getter is_local_storage : Bool
    end

    # DOM Storage item.
    alias Item = Array(String)

    # ----------------------------------------
    # DOMStorage Section: commands
    # ----------------------------------------

    struct Clear
      include Protocol::Command
      include JSON::Serializable
    end

    # Disables storage tracking, prevents storage events from being sent to the client.
    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    # Enables storage tracking, storage events will now be delivered to the client.
    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    struct GetDOMStorageItems
      include Protocol::Command
      include JSON::Serializable
      getter entries : Array(Item)
    end

    struct RemoveDOMStorageItem
      include Protocol::Command
      include JSON::Serializable
    end

    struct SetDOMStorageItem
      include Protocol::Command
      include JSON::Serializable
    end

    # ----------------------------------------
    # DOMStorage Section: events
    # ----------------------------------------

    struct DomStorageItemAdded
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "storageId")]
      getter storage_id : StorageId
      getter key : String
      @[JSON::Field(key: "newValue")]
      getter new_value : String
    end

    struct DomStorageItemRemoved
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "storageId")]
      getter storage_id : StorageId
      getter key : String
    end

    struct DomStorageItemUpdated
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "storageId")]
      getter storage_id : StorageId
      getter key : String
      @[JSON::Field(key: "oldValue")]
      getter old_value : String
      @[JSON::Field(key: "newValue")]
      getter new_value : String
    end

    struct DomStorageItemsCleared
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "storageId")]
      getter storage_id : StorageId
    end
  end
end
