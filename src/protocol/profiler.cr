# Profiler module dependencies
require "./runtime"
require "./debugger"

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module Profiler
    # ----------------------------------------
    # Profiler Section: types
    # ----------------------------------------

    # Profile node. Holds callsite information, execution statistics and child nodes.
    struct ProfileNode
      include JSON::Serializable
      # Unique id of the node.
      getter id : Int::Primitive
      @[JSON::Field(key: "callFrame")]
      # Function location.
      getter call_frame : Runtime::CallFrame
      @[JSON::Field(key: "hitCount")]
      # Number of samples where this node was on top of the call stack.
      getter hit_count : Int::Primitive?
      # Child node ids.
      getter children : Array(Int::Primitive)?
      @[JSON::Field(key: "deoptReason")]
      # The reason of being not optimized. The function may be deoptimized or marked as don't
      # optimize.
      getter deopt_reason : String?
      @[JSON::Field(key: "positionTicks")]
      # An array of source position ticks.
      getter position_ticks : Array(PositionTickInfo)?
    end

    # Profile.
    struct Profile
      include JSON::Serializable
      # The list of profile nodes. First item is the root node.
      getter nodes : Array(ProfileNode)
      @[JSON::Field(key: "startTime")]
      # Profiling start timestamp in microseconds.
      getter start_time : Number::Primitive
      @[JSON::Field(key: "endTime")]
      # Profiling end timestamp in microseconds.
      getter end_time : Number::Primitive
      # Ids of samples top nodes.
      getter samples : Array(Int::Primitive)?
      @[JSON::Field(key: "timeDeltas")]
      # Time intervals between adjacent samples in microseconds. The first delta is relative to the
      # profile startTime.
      getter time_deltas : Array(Int::Primitive)?
    end

    # Specifies a number of samples attributed to a certain source position.
    struct PositionTickInfo
      include JSON::Serializable
      # Source line number (1-based).
      getter line : Int::Primitive
      # Number of samples attributed to the source line.
      getter ticks : Int::Primitive
    end

    # Coverage data for a source range.
    struct CoverageRange
      include JSON::Serializable
      @[JSON::Field(key: "startOffset")]
      # JavaScript script source offset for the range start.
      getter start_offset : Int::Primitive
      @[JSON::Field(key: "endOffset")]
      # JavaScript script source offset for the range end.
      getter end_offset : Int::Primitive
      # Collected execution count of the source range.
      getter count : Int::Primitive
    end

    # Coverage data for a JavaScript function.
    struct FunctionCoverage
      include JSON::Serializable
      @[JSON::Field(key: "functionName")]
      # JavaScript function name.
      getter function_name : String
      # Source ranges inside the function with coverage data.
      getter ranges : Array(CoverageRange)
      @[JSON::Field(key: "isBlockCoverage")]
      # Whether coverage data for this function has block granularity.
      getter is_block_coverage : Bool
    end

    # Coverage data for a JavaScript script.
    struct ScriptCoverage
      include JSON::Serializable
      @[JSON::Field(key: "scriptId")]
      # JavaScript script id.
      getter script_id : Runtime::ScriptId
      # JavaScript script name or url.
      getter url : String
      # Functions contained in the script that has coverage data.
      getter functions : Array(FunctionCoverage)
    end

    # ----------------------------------------
    # Profiler Section: commands
    # ----------------------------------------

    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    # Collect coverage data for the current isolate. The coverage data may be incomplete due to
    # garbage collection.
    struct GetBestEffortCoverage
      include Protocol::Command
      include JSON::Serializable
      # Coverage data for the current isolate.
      getter result : Array(ScriptCoverage)
    end

    # Changes CPU profiler sampling interval. Must be called before CPU profiles recording started.
    struct SetSamplingInterval
      include Protocol::Command
      include JSON::Serializable
    end

    struct Start
      include Protocol::Command
      include JSON::Serializable
    end

    # Enable precise code coverage. Coverage data for JavaScript executed before enabling precise code
    # coverage may be incomplete. Enabling prevents running optimized code and resets execution
    # counters.
    struct StartPreciseCoverage
      include Protocol::Command
      include JSON::Serializable
      # Monotonically increasing time (in seconds) when the coverage update was taken in the backend.
      getter timestamp : Number::Primitive
    end

    struct Stop
      include Protocol::Command
      include JSON::Serializable
      # Recorded profile.
      getter profile : Profile
    end

    # Disable precise code coverage. Disabling releases unnecessary execution count records and allows
    # executing optimized code.
    struct StopPreciseCoverage
      include Protocol::Command
      include JSON::Serializable
    end

    # Collect coverage data for the current isolate, and resets execution counters. Precise code
    # coverage needs to have started.
    struct TakePreciseCoverage
      include Protocol::Command
      include JSON::Serializable
      # Coverage data for the current isolate.
      getter result : Array(ScriptCoverage)
      # Monotonically increasing time (in seconds) when the coverage update was taken in the backend.
      getter timestamp : Number::Primitive
    end

    # ----------------------------------------
    # Profiler Section: events
    # ----------------------------------------

    struct ConsoleProfileFinished
      include JSON::Serializable
      include Protocol::Event
      getter id : String
      # Location of console.profileEnd().
      getter location : Debugger::Location
      getter profile : Profile
      # Profile title passed as an argument to console.profile().
      getter title : String?
    end

    # Sent when new profile recording is started using console.profile() call.
    struct ConsoleProfileStarted
      include JSON::Serializable
      include Protocol::Event
      getter id : String
      # Location of console.profile().
      getter location : Debugger::Location
      # Profile title passed as an argument to console.profile().
      getter title : String?
    end

    # Reports coverage delta since the last poll (either from an event like this, or from
    # `takePreciseCoverage` for the current isolate. May only be sent if precise code
    # coverage has been started. This event can be trigged by the embedder to, for example,
    # trigger collection of coverage data immediately at a certain point in time.
    struct PreciseCoverageDeltaUpdate
      include JSON::Serializable
      include Protocol::Event
      # Monotonically increasing time (in seconds) when the coverage update was taken in the backend.
      getter timestamp : Number::Primitive
      # Identifier for distinguishing coverage events.
      getter occasion : String
      # Coverage data for the current isolate.
      getter result : Array(ScriptCoverage)
    end
  end
end
