# ================================================================================
# DOM debugging allows setting breakpoints on particular DOM operations and events. JavaScript
# execution will stop on these operations as if there was a regular breakpoint set.
# ================================================================================

# DOMDebugger module dependencies
require "./dom"
require "./debugger"
require "./runtime"

# common Command module
require "./command"

module Protocol
  module DOMDebugger
    # ----------------------------------------
    # DOMDebugger Section: types
    # ----------------------------------------

    # DOM breakpoint type.
    @[DashEnum]
    enum DOMBreakpointType
      SubtreeModified   # subtree-modified
      AttributeModified # attribute-modified
      NodeRemoved       # node-removed
    end

    # CSP Violation type.
    @[DashEnum]
    enum CSPViolationType
      TrustedtypeSinkViolation   # trustedtype-sink-violation
      TrustedtypePolicyViolation # trustedtype-policy-violation
    end

    # Object event listener.
    struct EventListener
      include JSON::Serializable
      # `EventListener`'s type.
      getter type : String
      @[JSON::Field(key: "useCapture")]
      # `EventListener`'s useCapture.
      getter use_capture : Bool
      # `EventListener`'s passive flag.
      getter passive : Bool
      # `EventListener`'s once flag.
      getter once : Bool
      @[JSON::Field(key: "scriptId")]
      # Script id of the handler code.
      getter script_id : Runtime::ScriptId
      @[JSON::Field(key: "lineNumber")]
      # Line number in the script (0-based).
      getter line_number : Int::Primitive
      @[JSON::Field(key: "columnNumber")]
      # Column number in the script (0-based).
      getter column_number : Int::Primitive
      # Event handler function value.
      getter handler : Runtime::RemoteObject?
      @[JSON::Field(key: "originalHandler")]
      # Event original handler function value.
      getter original_handler : Runtime::RemoteObject?
      @[JSON::Field(key: "backendNodeId")]
      # Node the listener is added to (if any).
      getter backend_node_id : DOM::BackendNodeId?
    end

    # ----------------------------------------
    # DOMDebugger Section: commands
    # ----------------------------------------

    # Returns event listeners of the given object.
    struct GetEventListeners
      include Protocol::Command
      include JSON::Serializable
      # Array of relevant listeners.
      getter listeners : Array(EventListener)
    end

    # Removes DOM breakpoint that was set using `setDOMBreakpoint`.
    struct RemoveDOMBreakpoint
      include Protocol::Command
      include JSON::Serializable
    end

    # Removes breakpoint on particular DOM event.
    struct RemoveEventListenerBreakpoint
      include Protocol::Command
      include JSON::Serializable
    end

    # Removes breakpoint on particular native event.
    struct RemoveInstrumentationBreakpoint
      include Protocol::Command
      include JSON::Serializable
    end

    # Removes breakpoint from XMLHttpRequest.
    struct RemoveXHRBreakpoint
      include Protocol::Command
      include JSON::Serializable
    end

    # Sets breakpoint on particular CSP violations.
    struct SetBreakOnCSPViolation
      include Protocol::Command
      include JSON::Serializable
    end

    # Sets breakpoint on particular operation with DOM.
    struct SetDOMBreakpoint
      include Protocol::Command
      include JSON::Serializable
    end

    # Sets breakpoint on particular DOM event.
    struct SetEventListenerBreakpoint
      include Protocol::Command
      include JSON::Serializable
    end

    # Sets breakpoint on particular native event.
    struct SetInstrumentationBreakpoint
      include Protocol::Command
      include JSON::Serializable
    end

    # Sets breakpoint on XMLHttpRequest.
    struct SetXHRBreakpoint
      include Protocol::Command
      include JSON::Serializable
    end
  end
end
