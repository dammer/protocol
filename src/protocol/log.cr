# ===============================
# Provides access to log entries.
# ===============================

# Log module dependencies
require "./runtime"
require "./network"

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module Log
    # ----------------------------------------
    # Log Section: types
    # ----------------------------------------

    # Log entry.
    struct LogEntry
      include JSON::Serializable
      # Log entry source.
      getter source : String
      # Log entry severity.
      getter level : String
      # Logged text.
      getter text : String
      getter category : String?
      # Timestamp when this entry was added.
      getter timestamp : Runtime::Timestamp
      # URL of the resource if known.
      getter url : String?
      @[JSON::Field(key: "lineNumber")]
      # Line number in the resource.
      getter line_number : Int::Primitive?
      @[JSON::Field(key: "stackTrace")]
      # JavaScript stack trace.
      getter stack_trace : Runtime::StackTrace?
      @[JSON::Field(key: "networkRequestId")]
      # Identifier of the network request associated with this entry.
      getter network_request_id : Network::RequestId?
      @[JSON::Field(key: "workerId")]
      # Identifier of the worker associated with this entry.
      getter worker_id : String?
      # Call arguments.
      getter args : Array(Runtime::RemoteObject)?
    end

    # Violation configuration setting.
    struct ViolationSetting
      include JSON::Serializable
      # Violation type.
      getter name : String
      # Time threshold to trigger upon.
      getter threshold : Number::Primitive
    end

    # ----------------------------------------
    # Log Section: commands
    # ----------------------------------------

    # Clears the log.
    struct Clear
      include Protocol::Command
      include JSON::Serializable
    end

    # Disables log domain, prevents further log entries from being reported to the client.
    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    # Enables log domain, sends the entries collected so far to the client by means of the
    # `entryAdded` notification.
    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    # start violation reporting.
    struct StartViolationsReport
      include Protocol::Command
      include JSON::Serializable
    end

    # Stop violation reporting.
    struct StopViolationsReport
      include Protocol::Command
      include JSON::Serializable
    end

    # ----------------------------------------
    # Log Section: events
    # ----------------------------------------

    # Issued when new message was logged.
    struct EntryAdded
      include JSON::Serializable
      include Protocol::Event
      # The entry.
      getter entry : LogEntry
    end
  end
end
