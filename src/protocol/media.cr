# ========================================================
# This domain allows detailed inspection of media elements
# ========================================================

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module Media
    # ----------------------------------------
    # Media Section: types
    # ----------------------------------------

    # Players will get an ID that is unique within the agent context.
    alias PlayerId = String

    alias Timestamp = Number::Primitive

    # Have one type per entry in MediaLogRecord::Type
    # Corresponds to kMessage
    struct PlayerMessage
      include JSON::Serializable
      # Keep in sync with MediaLogMessageLevel
      # We are currently keeping the message level 'error' separate from the
      # PlayerError type because right now they represent different things,
      # this one being a DVLOG(ERROR) style log message that gets printed
      # based on what log level is selected in the UI, and the other is a
      # representation of a media::PipelineStatus object. Soon however we're
      # going to be moving away from using PipelineStatus for errors and
      # introducing a new error type which should hopefully let us integrate
      # the error log level into the PlayerError type.
      getter level : String
      getter message : String
    end

    # Corresponds to kMediaPropertyChange
    struct PlayerProperty
      include JSON::Serializable
      getter name : String
      getter value : String
    end

    # Corresponds to kMediaEventTriggered
    struct PlayerEvent
      include JSON::Serializable
      getter timestamp : Timestamp
      getter value : String
    end

    # Represents logged source line numbers reported in an error.
    # NOTE: file and line are from chromium c++ implementation code, not js.
    struct PlayerErrorSourceLocation
      include JSON::Serializable
      getter file : String
      getter line : Int::Primitive
    end

    # Corresponds to kMediaError
    struct PlayerError
      include JSON::Serializable
      @[JSON::Field(key: "errorType")]
      getter error_type : String
      # Code is the numeric enum entry for a specific set of error codes, such
      # as PipelineStatusCodes in media/base/pipeline_status.h
      getter code : Int::Primitive
      # A trace of where this error was caused / where it passed through.
      getter stack : Array(PlayerErrorSourceLocation)
      # Errors potentially have a root cause error, ie, a DecoderError might be
      # caused by an WindowsError
      getter cause : Array(PlayerError)
      # Extra data attached to an error, such as an HRESULT, Video Codec, etc.
      getter data : JSON::Any
    end

    # ----------------------------------------
    # Media Section: commands
    # ----------------------------------------

    # Enables the Media domain
    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    # Disables the Media domain.
    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    # ----------------------------------------
    # Media Section: events
    # ----------------------------------------

    # This can be called multiple times, and can be used to set / override /
    # remove player properties. A null propValue indicates removal.
    struct PlayerPropertiesChanged
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "playerId")]
      getter player_id : PlayerId
      getter properties : Array(PlayerProperty)
    end

    # Send events as a list, allowing them to be batched on the browser for less
    # congestion. If batched, events must ALWAYS be in chronological order.
    struct PlayerEventsAdded
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "playerId")]
      getter player_id : PlayerId
      getter events : Array(PlayerEvent)
    end

    # Send a list of any messages that need to be delivered.
    struct PlayerMessagesLogged
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "playerId")]
      getter player_id : PlayerId
      getter messages : Array(PlayerMessage)
    end

    # Send a list of any errors that need to be delivered.
    struct PlayerErrorsRaised
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "playerId")]
      getter player_id : PlayerId
      getter errors : Array(PlayerError)
    end

    # Called whenever a player is created, or when a new agent joins and receives
    # a list of active players. If an agent is restored, it will receive the full
    # list of player ids and all events again.
    struct PlayersCreated
      include JSON::Serializable
      include Protocol::Event
      getter players : Array(PlayerId)
    end
  end
end
