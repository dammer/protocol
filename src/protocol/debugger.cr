# ================================================================================
# Debugger domain exposes JavaScript debugging capabilities. It allows setting and removing
# breakpoints, stepping through execution, exploring stack traces, etc.
# ================================================================================

# Debugger module dependencies
require "./runtime"

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module Debugger
    # ----------------------------------------
    # Debugger Section: types
    # ----------------------------------------

    # Breakpoint identifier.
    alias BreakpointId = String

    # Call frame identifier.
    alias CallFrameId = String

    # Location in the source code.
    struct Location
      include JSON::Serializable
      @[JSON::Field(key: "scriptId")]
      # Script identifier as reported in the `Debugger.scriptParsed`.
      getter script_id : Runtime::ScriptId
      @[JSON::Field(key: "lineNumber")]
      # Line number in the script (0-based).
      getter line_number : Int::Primitive
      @[JSON::Field(key: "columnNumber")]
      # Column number in the script (0-based).
      getter column_number : Int::Primitive?
    end

    # Location in the source code.
    struct ScriptPosition
      include JSON::Serializable
      @[JSON::Field(key: "lineNumber")]
      getter line_number : Int::Primitive
      @[JSON::Field(key: "columnNumber")]
      getter column_number : Int::Primitive
    end

    # Location range within one script.
    struct LocationRange
      include JSON::Serializable
      @[JSON::Field(key: "scriptId")]
      getter script_id : Runtime::ScriptId
      getter start : ScriptPosition
      getter end : ScriptPosition
    end

    # JavaScript call frame. Array of call frames form the call stack.
    struct CallFrame
      include JSON::Serializable
      @[JSON::Field(key: "callFrameId")]
      # Call frame identifier. This identifier is only valid while the virtual machine is paused.
      getter call_frame_id : CallFrameId
      @[JSON::Field(key: "functionName")]
      # Name of the JavaScript function called on this call frame.
      getter function_name : String
      @[JSON::Field(key: "functionLocation")]
      # Location in the source code.
      getter function_location : Location?
      # Location in the source code.
      getter location : Location
      # JavaScript script name or url.
      # Deprecated in favor of using the `location.scriptId` to resolve the URL via a previously
      # sent `Debugger.scriptParsed` event.
      getter url : String
      @[JSON::Field(key: "scopeChain")]
      # Scope chain for this call frame.
      getter scope_chain : Array(Scope)
      # `this` object for this call frame.
      getter this : Runtime::RemoteObject
      @[JSON::Field(key: "returnValue")]
      # The value being returned, if the function is at return point.
      getter return_value : Runtime::RemoteObject?
      @[JSON::Field(key: "canBeRestarted")]
      # Valid only while the VM is paused and indicates whether this frame
      # can be restarted or not. Note that a `true` value here does not
      # guarantee that Debugger#restartFrame with this CallFrameId will be
      # successful, but it is very likely.
      getter can_be_restarted : Bool?
    end

    # Scope description.
    struct Scope
      include JSON::Serializable
      # Scope type.
      getter type : String
      # Object representing the scope. For `global` and `with` scopes it represents the actual
      # object; for the rest of the scopes, it is artificial transient object enumerating scope
      # variables as its properties.
      getter object : Runtime::RemoteObject
      getter name : String?
      @[JSON::Field(key: "startLocation")]
      # Location in the source code where scope starts
      getter start_location : Location?
      @[JSON::Field(key: "endLocation")]
      # Location in the source code where scope ends
      getter end_location : Location?
    end

    # Search match for resource.
    struct SearchMatch
      include JSON::Serializable
      @[JSON::Field(key: "lineNumber")]
      # Line number in resource content.
      getter line_number : Number::Primitive
      @[JSON::Field(key: "lineContent")]
      # Line with match content.
      getter line_content : String
    end

    struct BreakLocation
      include JSON::Serializable
      @[JSON::Field(key: "scriptId")]
      # Script identifier as reported in the `Debugger.scriptParsed`.
      getter script_id : Runtime::ScriptId
      @[JSON::Field(key: "lineNumber")]
      # Line number in the script (0-based).
      getter line_number : Int::Primitive
      @[JSON::Field(key: "columnNumber")]
      # Column number in the script (0-based).
      getter column_number : Int::Primitive?
      getter type : String?
    end

    struct WasmDisassemblyChunk
      include JSON::Serializable
      # The next chunk of disassembled lines.
      getter lines : Array(String)
      @[JSON::Field(key: "bytecodeOffsets")]
      # The bytecode offsets describing the start of each line.
      getter bytecode_offsets : Array(Int::Primitive)
    end

    # Enum of possible script languages.
    enum ScriptLanguage
      JavaScript  # JavaScript
      WebAssembly # WebAssembly
    end

    # Debug symbols available for a wasm script.
    struct DebugSymbols
      include JSON::Serializable
      # Type of the debug symbols.
      getter type : String
      @[JSON::Field(key: "externalURL")]
      # URL of the external symbol source.
      getter external_url : String?
    end

    # ----------------------------------------
    # Debugger Section: commands
    # ----------------------------------------

    # Continues execution until specific location is reached.
    struct ContinueToLocation
      include Protocol::Command
      include JSON::Serializable
    end

    # Disables debugger for given page.
    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    # Enables debugger for the given page. Clients should not assume that the debugging has been
    # enabled until the result for this command is received.
    struct Enable
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "debuggerId")]
      # Unique identifier of the debugger.
      getter debugger_id : Runtime::UniqueDebuggerId
    end

    # Evaluates expression on a given call frame.
    struct EvaluateOnCallFrame
      include Protocol::Command
      include JSON::Serializable
      # Object wrapper for the evaluation result.
      getter result : Runtime::RemoteObject
      @[JSON::Field(key: "exceptionDetails")]
      # Exception details.
      getter exception_details : Runtime::ExceptionDetails?
    end

    # Returns possible locations for breakpoint. scriptId in start and end range locations should be
    # the same.
    struct GetPossibleBreakpoints
      include Protocol::Command
      include JSON::Serializable
      # List of the possible breakpoint locations.
      getter locations : Array(BreakLocation)
    end

    # Returns source for the script with given id.
    struct GetScriptSource
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "scriptSource")]
      # Script source (empty in case of Wasm bytecode).
      getter script_source : String
      # Wasm bytecode. (Encoded as a base64 string when passed over JSON)
      getter bytecode : String?
    end

    struct DisassembleWasmModule
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "streamId")]
      # For large modules, return a stream from which additional chunks of
      # disassembly can be read successively.
      getter stream_id : String?
      @[JSON::Field(key: "totalNumberOfLines")]
      # The total number of lines in the disassembly text.
      getter total_number_of_lines : Int::Primitive
      @[JSON::Field(key: "functionBodyOffsets")]
      # The offsets of all function bodies, in the format [start1, end1,
      # start2, end2, ...] where all ends are exclusive.
      getter function_body_offsets : Array(Int::Primitive)
      # The first chunk of disassembly.
      getter chunk : WasmDisassemblyChunk
    end

    # Disassemble the next chunk of lines for the module corresponding to the
    # stream. If disassembly is complete, this API will invalidate the streamId
    # and return an empty chunk. Any subsequent calls for the now invalid stream
    # will return errors.
    struct NextWasmDisassemblyChunk
      include Protocol::Command
      include JSON::Serializable
      # The next chunk of disassembly.
      getter chunk : WasmDisassemblyChunk
    end

    # This command is deprecated. Use getScriptSource instead.
    struct GetWasmBytecode
      include Protocol::Command
      include JSON::Serializable
      # Script source. (Encoded as a base64 string when passed over JSON)
      getter bytecode : String
    end

    # Returns stack trace with given `stackTraceId`.
    struct GetStackTrace
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "stackTrace")]
      getter stack_trace : Runtime::StackTrace
    end

    # Stops on the next JavaScript statement.
    struct Pause
      include Protocol::Command
      include JSON::Serializable
    end

    struct PauseOnAsyncCall
      include Protocol::Command
      include JSON::Serializable
    end

    # Removes JavaScript breakpoint.
    struct RemoveBreakpoint
      include Protocol::Command
      include JSON::Serializable
    end

    # Restarts particular call frame from the beginning. The old, deprecated
    # behavior of `restartFrame` is to stay paused and allow further CDP commands
    # after a restart was scheduled. This can cause problems with restarting, so
    # we now continue execution immediatly after it has been scheduled until we
    # reach the beginning of the restarted frame.
    #
    # To stay back-wards compatible, `restartFrame` now expects a `mode`
    # parameter to be present. If the `mode` parameter is missing, `restartFrame`
    # errors out.
    #
    # The various return values are deprecated and `callFrames` is always empty.
    # Use the call frames from the `Debugger#paused` events instead, that fires
    # once V8 pauses at the beginning of the restarted function.
    struct RestartFrame
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "callFrames")]
      # New stack trace.
      getter call_frames : Array(CallFrame)
      @[JSON::Field(key: "asyncStackTrace")]
      # Async stack trace, if any.
      getter async_stack_trace : Runtime::StackTrace?
      @[JSON::Field(key: "asyncStackTraceId")]
      # Async stack trace, if any.
      getter async_stack_trace_id : Runtime::StackTraceId?
    end

    # Resumes JavaScript execution.
    struct Resume
      include Protocol::Command
      include JSON::Serializable
    end

    # Searches for given string in script content.
    struct SearchInContent
      include Protocol::Command
      include JSON::Serializable
      # List of search matches.
      getter result : Array(SearchMatch)
    end

    # Enables or disables async call stacks tracking.
    struct SetAsyncCallStackDepth
      include Protocol::Command
      include JSON::Serializable
    end

    # Replace previous blackbox patterns with passed ones. Forces backend to skip stepping/pausing in
    # scripts with url matching one of the patterns. VM will try to leave blackboxed script by
    # performing 'step in' several times, finally resorting to 'step out' if unsuccessful.
    struct SetBlackboxPatterns
      include Protocol::Command
      include JSON::Serializable
    end

    # Makes backend skip steps in the script in blackboxed ranges. VM will try leave blacklisted
    # scripts by performing 'step in' several times, finally resorting to 'step out' if unsuccessful.
    # Positions array contains positions where blackbox state is changed. First interval isn't
    # blackboxed. Array should be sorted.
    struct SetBlackboxedRanges
      include Protocol::Command
      include JSON::Serializable
    end

    # Sets JavaScript breakpoint at a given location.
    struct SetBreakpoint
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "breakpointId")]
      # Id of the created breakpoint for further reference.
      getter breakpoint_id : BreakpointId
      @[JSON::Field(key: "actualLocation")]
      # Location this breakpoint resolved into.
      getter actual_location : Location
    end

    # Sets instrumentation breakpoint.
    struct SetInstrumentationBreakpoint
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "breakpointId")]
      # Id of the created breakpoint for further reference.
      getter breakpoint_id : BreakpointId
    end

    # Sets JavaScript breakpoint at given location specified either by URL or URL regex. Once this
    # command is issued, all existing parsed scripts will have breakpoints resolved and returned in
    # `locations` property. Further matching script parsing will result in subsequent
    # `breakpointResolved` events issued. This logical breakpoint will survive page reloads.
    struct SetBreakpointByUrl
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "breakpointId")]
      # Id of the created breakpoint for further reference.
      getter breakpoint_id : BreakpointId
      # List of the locations this breakpoint resolved into upon addition.
      getter locations : Array(Location)
    end

    # Sets JavaScript breakpoint before each call to the given function.
    # If another function was created from the same source as a given one,
    # calling it will also trigger the breakpoint.
    struct SetBreakpointOnFunctionCall
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "breakpointId")]
      # Id of the created breakpoint for further reference.
      getter breakpoint_id : BreakpointId
    end

    # Activates / deactivates all breakpoints on the page.
    struct SetBreakpointsActive
      include Protocol::Command
      include JSON::Serializable
    end

    # Defines pause on exceptions state. Can be set to stop on all exceptions, uncaught exceptions or
    # no exceptions. Initial pause on exceptions state is `none`.
    struct SetPauseOnExceptions
      include Protocol::Command
      include JSON::Serializable
    end

    # Changes return value in top frame. Available only at return break position.
    struct SetReturnValue
      include Protocol::Command
      include JSON::Serializable
    end

    # Edits JavaScript source live.
    #
    # In general, functions that are currently on the stack can not be edited with
    # a single exception: If the edited function is the top-most stack frame and
    # that is the only activation of that function on the stack. In this case
    # the live edit will be successful and a `Debugger.restartFrame` for the
    # top-most function is automatically triggered.
    struct SetScriptSource
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "callFrames")]
      # New stack trace in case editing has happened while VM was stopped.
      getter call_frames : Array(CallFrame)?
      @[JSON::Field(key: "stackChanged")]
      # Whether current call stack  was modified after applying the changes.
      getter stack_changed : Bool?
      @[JSON::Field(key: "asyncStackTrace")]
      # Async stack trace, if any.
      getter async_stack_trace : Runtime::StackTrace?
      @[JSON::Field(key: "asyncStackTraceId")]
      # Async stack trace, if any.
      getter async_stack_trace_id : Runtime::StackTraceId?
      # Whether the operation was successful or not. Only `Ok` denotes a
      # successful live edit while the other enum variants denote why
      # the live edit failed.
      getter status : String
      @[JSON::Field(key: "exceptionDetails")]
      # Exception details if any. Only present when `status` is `CompileError`.
      getter exception_details : Runtime::ExceptionDetails?
    end

    # Makes page not interrupt on any pauses (breakpoint, exception, dom exception etc).
    struct SetSkipAllPauses
      include Protocol::Command
      include JSON::Serializable
    end

    # Changes value of variable in a callframe. Object-based scopes are not supported and must be
    # mutated manually.
    struct SetVariableValue
      include Protocol::Command
      include JSON::Serializable
    end

    # Steps into the function call.
    struct StepInto
      include Protocol::Command
      include JSON::Serializable
    end

    # Steps out of the function call.
    struct StepOut
      include Protocol::Command
      include JSON::Serializable
    end

    # Steps over the statement.
    struct StepOver
      include Protocol::Command
      include JSON::Serializable
    end

    # ----------------------------------------
    # Debugger Section: events
    # ----------------------------------------

    # Fired when breakpoint is resolved to an actual script and location.
    struct BreakpointResolved
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "breakpointId")]
      # Breakpoint unique identifier.
      getter breakpoint_id : BreakpointId
      # Actual breakpoint location.
      getter location : Location
    end

    # Fired when the virtual machine stopped on breakpoint or exception or any other stop criteria.
    struct Paused
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "callFrames")]
      # Call stack the virtual machine stopped on.
      getter call_frames : Array(CallFrame)
      # Pause reason.
      getter reason : String
      # Object containing break-specific auxiliary properties.
      getter data : JSON::Any?
      @[JSON::Field(key: "hitBreakpoints")]
      # Hit breakpoints IDs
      getter hit_breakpoints : Array(String)?
      @[JSON::Field(key: "asyncStackTrace")]
      # Async stack trace, if any.
      getter async_stack_trace : Runtime::StackTrace?
      @[JSON::Field(key: "asyncStackTraceId")]
      # Async stack trace, if any.
      getter async_stack_trace_id : Runtime::StackTraceId?
      @[JSON::Field(key: "asyncCallStackTraceId")]
      # Never present, will be removed.
      getter async_call_stack_trace_id : Runtime::StackTraceId?
    end

    # Fired when the virtual machine resumed execution.
    struct Resumed
      include JSON::Serializable
      include Protocol::Event
    end

    # Fired when virtual machine fails to parse the script.
    struct ScriptFailedToParse
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "scriptId")]
      # Identifier of the script parsed.
      getter script_id : Runtime::ScriptId
      # URL or name of the script parsed (if any).
      getter url : String
      @[JSON::Field(key: "startLine")]
      # Line offset of the script within the resource with given URL (for script tags).
      getter start_line : Int::Primitive
      @[JSON::Field(key: "startColumn")]
      # Column offset of the script within the resource with given URL.
      getter start_column : Int::Primitive
      @[JSON::Field(key: "endLine")]
      # Last line of the script.
      getter end_line : Int::Primitive
      @[JSON::Field(key: "endColumn")]
      # Length of the last line of the script.
      getter end_column : Int::Primitive
      @[JSON::Field(key: "executionContextId")]
      # Specifies script creation context.
      getter execution_context_id : Runtime::ExecutionContextId
      # Content hash of the script, SHA-256.
      getter hash : String
      @[JSON::Field(key: "executionContextAuxData")]
      # Embedder-specific auxiliary data.
      getter execution_context_aux_data : JSON::Any?
      @[JSON::Field(key: "sourceMapURL")]
      # URL of source map associated with script (if any).
      getter source_map_url : String?
      @[JSON::Field(key: "hasSourceURL")]
      # True, if this script has sourceURL.
      getter has_source_url : Bool?
      @[JSON::Field(key: "isModule")]
      # True, if this script is ES6 module.
      getter is_module : Bool?
      # This script length.
      getter length : Int::Primitive?
      @[JSON::Field(key: "stackTrace")]
      # JavaScript top stack frame of where the script parsed event was triggered if available.
      getter stack_trace : Runtime::StackTrace?
      @[JSON::Field(key: "codeOffset")]
      # If the scriptLanguage is WebAssembly, the code section offset in the module.
      getter code_offset : Int::Primitive?
      @[JSON::Field(key: "scriptLanguage")]
      # The language of the script.
      getter script_language : Debugger::ScriptLanguage?
      @[JSON::Field(key: "embedderName")]
      # The name the embedder supplied for this script.
      getter embedder_name : String?
    end

    # Fired when virtual machine parses script. This event is also fired for all known and uncollected
    # scripts upon enabling debugger.
    struct ScriptParsed
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "scriptId")]
      # Identifier of the script parsed.
      getter script_id : Runtime::ScriptId
      # URL or name of the script parsed (if any).
      getter url : String
      @[JSON::Field(key: "startLine")]
      # Line offset of the script within the resource with given URL (for script tags).
      getter start_line : Int::Primitive
      @[JSON::Field(key: "startColumn")]
      # Column offset of the script within the resource with given URL.
      getter start_column : Int::Primitive
      @[JSON::Field(key: "endLine")]
      # Last line of the script.
      getter end_line : Int::Primitive
      @[JSON::Field(key: "endColumn")]
      # Length of the last line of the script.
      getter end_column : Int::Primitive
      @[JSON::Field(key: "executionContextId")]
      # Specifies script creation context.
      getter execution_context_id : Runtime::ExecutionContextId
      # Content hash of the script, SHA-256.
      getter hash : String
      @[JSON::Field(key: "executionContextAuxData")]
      # Embedder-specific auxiliary data.
      getter execution_context_aux_data : JSON::Any?
      @[JSON::Field(key: "isLiveEdit")]
      # True, if this script is generated as a result of the live edit operation.
      getter is_live_edit : Bool?
      @[JSON::Field(key: "sourceMapURL")]
      # URL of source map associated with script (if any).
      getter source_map_url : String?
      @[JSON::Field(key: "hasSourceURL")]
      # True, if this script has sourceURL.
      getter has_source_url : Bool?
      @[JSON::Field(key: "isModule")]
      # True, if this script is ES6 module.
      getter is_module : Bool?
      # This script length.
      getter length : Int::Primitive?
      @[JSON::Field(key: "stackTrace")]
      # JavaScript top stack frame of where the script parsed event was triggered if available.
      getter stack_trace : Runtime::StackTrace?
      @[JSON::Field(key: "codeOffset")]
      # If the scriptLanguage is WebAssembly, the code section offset in the module.
      getter code_offset : Int::Primitive?
      @[JSON::Field(key: "scriptLanguage")]
      # The language of the script.
      getter script_language : Debugger::ScriptLanguage?
      @[JSON::Field(key: "debugSymbols")]
      # If the scriptLanguage is WebASsembly, the source of debug symbols for the module.
      getter debug_symbols : Debugger::DebugSymbols?
      @[JSON::Field(key: "embedderName")]
      # The name the embedder supplied for this script.
      getter embedder_name : String?
    end
  end
end
