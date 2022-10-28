# ============================================================================
# EventBreakpoints permits setting breakpoints on particular operations and
# events in targets that run JavaScript but do not have a DOM.
# JavaScript execution will stop on these operations as if there was a regular
# breakpoint set.
# ============================================================================

# common Command module
require "./command"

module Protocol
  module EventBreakpoints
    # ----------------------------------------
    # EventBreakpoints Section: commands
    # ----------------------------------------

    # Sets breakpoint on particular native event.
    struct SetInstrumentationBreakpoint
      include Protocol::Command
      include JSON::Serializable
    end

    # Removes breakpoint on particular native event.
    struct RemoveInstrumentationBreakpoint
      include Protocol::Command
      include JSON::Serializable
    end
  end
end
