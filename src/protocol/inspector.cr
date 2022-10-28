# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module Inspector
    # ----------------------------------------
    # Inspector Section: commands
    # ----------------------------------------

    # Disables inspector domain notifications.
    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    # Enables inspector domain notifications.
    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    # ----------------------------------------
    # Inspector Section: events
    # ----------------------------------------

    # Fired when remote debugging connection is about to be terminated. Contains detach reason.
    struct Detached
      include JSON::Serializable
      include Protocol::Event
      # The reason why connection has been terminated.
      getter reason : String
    end

    # Fired when debugging target has crashed
    struct TargetCrashed
      include JSON::Serializable
      include Protocol::Event
    end

    # Fired when debugging target has reloaded after crash
    struct TargetReloadedAfterCrash
      include JSON::Serializable
      include Protocol::Event
    end
  end
end
