# Tracing module dependencies
require "./io"

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module Tracing
    # ----------------------------------------
    # Tracing Section: types
    # ----------------------------------------

    # Configuration for memory dump. Used only when "memory-infra" category is enabled.
    struct MemoryDumpConfig
      include JSON::Serializable
    end

    struct TraceConfig
      include JSON::Serializable
      @[JSON::Field(key: "recordMode")]
      # Controls how the trace buffer stores data.
      getter record_mode : String?
      @[JSON::Field(key: "traceBufferSizeInKb")]
      # Size of the trace buffer in kilobytes. If not specified or zero is passed, a default value
      # of 200 MB would be used.
      getter trace_buffer_size_in_kb : Number::Primitive?
      @[JSON::Field(key: "enableSampling")]
      # Turns on JavaScript stack sampling.
      getter enable_sampling : Bool?
      @[JSON::Field(key: "enableSystrace")]
      # Turns on system tracing.
      getter enable_systrace : Bool?
      @[JSON::Field(key: "enableArgumentFilter")]
      # Turns on argument filter.
      getter enable_argument_filter : Bool?
      @[JSON::Field(key: "includedCategories")]
      # Included category filters.
      getter included_categories : Array(String)?
      @[JSON::Field(key: "excludedCategories")]
      # Excluded category filters.
      getter excluded_categories : Array(String)?
      @[JSON::Field(key: "syntheticDelays")]
      # Configuration to synthesize the delays in tracing.
      getter synthetic_delays : Array(String)?
      @[JSON::Field(key: "memoryDumpConfig")]
      # Configuration for memory dump triggers. Used only when "memory-infra" category is enabled.
      getter memory_dump_config : MemoryDumpConfig?
    end

    # Data format of a trace. Can be either the legacy JSON format or the
    # protocol buffer format. Note that the JSON format will be deprecated soon.
    enum StreamFormat
      Json  # json
      Proto # proto
    end

    # Compression type to use for traces returned via streams.
    enum StreamCompression
      None # none
      Gzip # gzip
    end

    # Details exposed when memory request explicitly declared.
    # Keep consistent with memory_dump_request_args.h and
    # memory_instrumentation.mojom
    enum MemoryDumpLevelOfDetail
      Background # background
      Light      # light
      Detailed   # detailed
    end

    # Backend type to use for tracing. `chrome` uses the Chrome-integrated
    # tracing service and is supported on all platforms. `system` is only
    # supported on Chrome OS and uses the Perfetto system tracing service.
    # `auto` chooses `system` when the perfettoConfig provided to Tracing.start
    # specifies at least one non-Chrome data source; otherwise uses `chrome`.
    enum TracingBackend
      Auto   # auto
      Chrome # chrome
      System # system
    end

    # ----------------------------------------
    # Tracing Section: commands
    # ----------------------------------------

    # Stop trace events collection.
    struct End
      include Protocol::Command
      include JSON::Serializable
    end

    # Gets supported tracing categories.
    struct GetCategories
      include Protocol::Command
      include JSON::Serializable
      # A list of supported tracing categories.
      getter categories : Array(String)
    end

    # Record a clock sync marker in the trace.
    struct RecordClockSyncMarker
      include Protocol::Command
      include JSON::Serializable
    end

    # Request a global memory dump.
    struct RequestMemoryDump
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "dumpGuid")]
      # GUID of the resulting global memory dump.
      getter dump_guid : String
      # True iff the global memory dump succeeded.
      getter success : Bool
    end

    # Start trace events collection.
    struct Start
      include Protocol::Command
      include JSON::Serializable
    end

    # ----------------------------------------
    # Tracing Section: events
    # ----------------------------------------

    struct BufferUsage
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "percentFull")]
      # A number in range [0..1] that indicates the used size of event buffer as a fraction of its
      # total size.
      getter percent_full : Number::Primitive?
      @[JSON::Field(key: "eventCount")]
      # An approximate number of events in the trace log.
      getter event_count : Number::Primitive?
      # A number in range [0..1] that indicates the used size of event buffer as a fraction of its
      # total size.
      getter value : Number::Primitive?
    end

    # Contains an bucket of collected trace events. When tracing is stopped collected events will be
    # send as a sequence of dataCollected events followed by tracingComplete event.
    struct DataCollected
      include JSON::Serializable
      include Protocol::Event
      getter value : Array(JSON::Any)
    end

    # Signals that tracing is stopped and there is no trace buffers pending flush, all data were
    # delivered via dataCollected events.
    struct TracingComplete
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "dataLossOccurred")]
      # Indicates whether some trace data is known to have been lost, e.g. because the trace ring
      # buffer wrapped around.
      getter data_loss_occurred : Bool
      # A handle of the stream that holds resulting trace data.
      getter stream : IO::StreamHandle?
      @[JSON::Field(key: "traceFormat")]
      # Trace data format of returned stream.
      getter trace_format : StreamFormat?
      @[JSON::Field(key: "streamCompression")]
      # Compression format of returned stream.
      getter stream_compression : StreamCompression?
    end
  end
end
