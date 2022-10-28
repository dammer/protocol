# IndexedDB module dependencies
require "./runtime"

# common Command module
require "./command"

module Protocol
  module IndexedDB
    # ----------------------------------------
    # IndexedDB Section: types
    # ----------------------------------------

    # Database with an array of object stores.
    struct DatabaseWithObjectStores
      include JSON::Serializable
      # Database name.
      getter name : String
      # Database version (type is not 'integer', as the standard
      # requires the version number to be 'unsigned long long')
      getter version : Number::Primitive
      @[JSON::Field(key: "objectStores")]
      # Object stores in this database.
      getter object_stores : Array(ObjectStore)
    end

    # Object store.
    struct ObjectStore
      include JSON::Serializable
      # Object store name.
      getter name : String
      @[JSON::Field(key: "keyPath")]
      # Object store key path.
      getter key_path : KeyPath
      @[JSON::Field(key: "autoIncrement")]
      # If true, object store has auto increment flag set.
      getter auto_increment : Bool
      # Indexes in this object store.
      getter indexes : Array(ObjectStoreIndex)
    end

    # Object store index.
    struct ObjectStoreIndex
      include JSON::Serializable
      # Index name.
      getter name : String
      @[JSON::Field(key: "keyPath")]
      # Index key path.
      getter key_path : KeyPath
      # If true, index is unique.
      getter unique : Bool
      @[JSON::Field(key: "multiEntry")]
      # If true, index allows multiple entries for a key.
      getter multi_entry : Bool
    end

    # Key.
    struct Key
      include JSON::Serializable
      # Key type.
      getter type : String
      # Number value.
      getter number : Number::Primitive?
      # String value.
      getter string : String?
      # Date value.
      getter date : Number::Primitive?
      # Array value.
      getter array : Array(Key)?
    end

    # Key range.
    struct KeyRange
      include JSON::Serializable
      # Lower bound.
      getter lower : Key?
      # Upper bound.
      getter upper : Key?
      @[JSON::Field(key: "lowerOpen")]
      # If true lower bound is open.
      getter lower_open : Bool
      @[JSON::Field(key: "upperOpen")]
      # If true upper bound is open.
      getter upper_open : Bool
    end

    # Data entry.
    struct DataEntry
      include JSON::Serializable
      # Key object.
      getter key : Runtime::RemoteObject
      @[JSON::Field(key: "primaryKey")]
      # Primary key object.
      getter primary_key : Runtime::RemoteObject
      # Value object.
      getter value : Runtime::RemoteObject
    end

    # Key path.
    struct KeyPath
      include JSON::Serializable
      # Key path type.
      getter type : String
      # String value.
      getter string : String?
      # Array value.
      getter array : Array(String)?
    end

    # ----------------------------------------
    # IndexedDB Section: commands
    # ----------------------------------------

    # Clears all entries from an object store.
    struct ClearObjectStore
      include Protocol::Command
      include JSON::Serializable
    end

    # Deletes a database.
    struct DeleteDatabase
      include Protocol::Command
      include JSON::Serializable
    end

    # Delete a range of entries from an object store
    struct DeleteObjectStoreEntries
      include Protocol::Command
      include JSON::Serializable
    end

    # Disables events from backend.
    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    # Enables events from backend.
    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    # Requests data from object store or index.
    struct RequestData
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "objectStoreDataEntries")]
      # Array of object store data entries.
      getter object_store_data_entries : Array(DataEntry)
      @[JSON::Field(key: "hasMore")]
      # If true, there are more entries to fetch in the given range.
      getter has_more : Bool
    end

    # Gets metadata of an object store
    struct GetMetadata
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "entriesCount")]
      # the entries count
      getter entries_count : Number::Primitive
      @[JSON::Field(key: "keyGeneratorValue")]
      # the current value of key generator, to become the next inserted
      # key into the object store. Valid if objectStore.autoIncrement
      # is true.
      getter key_generator_value : Number::Primitive
    end

    # Requests database with given name in given frame.
    struct RequestDatabase
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "databaseWithObjectStores")]
      # Database with an array of object stores.
      getter database_with_object_stores : DatabaseWithObjectStores
    end

    # Requests database names for given security origin.
    struct RequestDatabaseNames
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "databaseNames")]
      # Database names for origin.
      getter database_names : Array(String)
    end
  end
end
