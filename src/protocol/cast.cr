# =============================================================================
# A domain for interacting with Cast, Presentation API, and Remote Playback API
# functionalities.
# =============================================================================

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module Cast
    # ----------------------------------------
    # Cast Section: types
    # ----------------------------------------

    struct Sink
      include JSON::Serializable
      getter name : String
      getter id : String
      # Text describing the current session. Present only if there is an active
      # session on the sink.
      getter session : String?
    end

    # ----------------------------------------
    # Cast Section: commands
    # ----------------------------------------

    # Starts observing for sinks that can be used for tab mirroring, and if set,
    # sinks compatible with |presentationUrl| as well. When sinks are found, a
    # |sinksUpdated| event is fired.
    # Also starts observing for issue messages. When an issue is added or removed,
    # an |issueUpdated| event is fired.
    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    # Stops observing for sinks and issues.
    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    # Sets a sink to be used when the web page requests the browser to choose a
    # sink via Presentation API, Remote Playback API, or Cast SDK.
    struct SetSinkToUse
      include Protocol::Command
      include JSON::Serializable
    end

    # Starts mirroring the desktop to the sink.
    struct StartDesktopMirroring
      include Protocol::Command
      include JSON::Serializable
    end

    # Starts mirroring the tab to the sink.
    struct StartTabMirroring
      include Protocol::Command
      include JSON::Serializable
    end

    # Stops the active Cast session on the sink.
    struct StopCasting
      include Protocol::Command
      include JSON::Serializable
    end

    # ----------------------------------------
    # Cast Section: events
    # ----------------------------------------

    # This is fired whenever the list of available sinks changes. A sink is a
    # device or a software surface that you can cast to.
    struct SinksUpdated
      include JSON::Serializable
      include Protocol::Event
      getter sinks : Array(Sink)
    end

    # This is fired whenever the outstanding issue/error message changes.
    # |issueMessage| is empty if there is no issue.
    struct IssueUpdated
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "issueMessage")]
      getter issue_message : String
    end
  end
end
