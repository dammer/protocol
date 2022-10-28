# =========================================================================
# The Tethering domain defines methods and events for browser port binding.
# =========================================================================

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module Tethering
    # ----------------------------------------
    # Tethering Section: commands
    # ----------------------------------------

    # Request browser port binding.
    struct Bind
      include Protocol::Command
      include JSON::Serializable
    end

    # Request browser port unbinding.
    struct Unbind
      include Protocol::Command
      include JSON::Serializable
    end

    # ----------------------------------------
    # Tethering Section: events
    # ----------------------------------------

    # Informs that port was successfully bound and got a specified connection id.
    struct Accepted
      include JSON::Serializable
      include Protocol::Event
      # Port number that was successfully bound.
      getter port : Int::Primitive
      @[JSON::Field(key: "connectionId")]
      # Connection id to be used.
      getter connection_id : String
    end
  end
end
