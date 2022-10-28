# =======================================================
# This domain is deprecated - use Runtime or Log instead.
# =======================================================

# Console module dependencies
require "./runtime"

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module Console
    # ----------------------------------------
    # Console Section: types
    # ----------------------------------------

    # Console message.
    struct ConsoleMessage
      include JSON::Serializable
      # Message source.
      getter source : String
      # Message severity.
      getter level : String
      # Message text.
      getter text : String
      # URL of the message origin.
      getter url : String?
      # Line number in the resource that generated this message (1-based).
      getter line : Int::Primitive?
      # Column number in the resource that generated this message (1-based).
      getter column : Int::Primitive?
    end

    # ----------------------------------------
    # Console Section: commands
    # ----------------------------------------

    # Does nothing.
    struct ClearMessages
      include Protocol::Command
      include JSON::Serializable
    end

    # Disables console domain, prevents further console messages from being reported to the client.
    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    # Enables console domain, sends the messages collected so far to the client by means of the
    # `messageAdded` notification.
    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    # ----------------------------------------
    # Console Section: events
    # ----------------------------------------

    # Issued when new console message is added.
    struct MessageAdded
      include JSON::Serializable
      include Protocol::Event
      # Console message that has been added.
      getter message : ConsoleMessage
    end
  end
end
