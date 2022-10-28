# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module Database
    # ----------------------------------------
    # Database Section: types
    # ----------------------------------------

    # Unique identifier of Database object.
    alias DatabaseId = String

    # Database object.
    struct Database
      include JSON::Serializable
      # Database ID.
      getter id : DatabaseId
      # Database domain.
      getter domain : String
      # Database name.
      getter name : String
      # Database version.
      getter version : String
    end

    # Database error.
    struct Error
      include JSON::Serializable
      # Error message.
      getter message : String
      # Error code.
      getter code : Int::Primitive
    end

    # ----------------------------------------
    # Database Section: commands
    # ----------------------------------------

    # Disables database tracking, prevents database events from being sent to the client.
    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    # Enables database tracking, database events will now be delivered to the client.
    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    struct ExecuteSQL
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "columnNames")]
      getter column_names : Array(String)?
      getter values : Array(JSON::Any)?
      @[JSON::Field(key: "sqlError")]
      getter sql_error : Error?
    end

    struct GetDatabaseTableNames
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "tableNames")]
      getter table_names : Array(String)
    end

    # ----------------------------------------
    # Database Section: events
    # ----------------------------------------

    struct AddDatabase
      include JSON::Serializable
      include Protocol::Event
      getter database : Database
    end
  end
end
