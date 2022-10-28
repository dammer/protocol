# common Command module
require "./command"

module Protocol
  module Memory
    # ----------------------------------------
    # Memory Section: types
    # ----------------------------------------

    # Memory pressure level.
    enum PressureLevel
      Moderate # moderate
      Critical # critical
    end

    # Heap profile sample.
    struct SamplingProfileNode
      include JSON::Serializable
      # Size of the sampled allocation.
      getter size : Number::Primitive
      # Total bytes attributed to this sample.
      getter total : Number::Primitive
      # Execution stack at the point of allocation.
      getter stack : Array(String)
    end

    # Array of heap profile samples.
    struct SamplingProfile
      include JSON::Serializable
      getter samples : Array(SamplingProfileNode)
      getter modules : Array(Module)
    end

    # Executable module information
    struct Module
      include JSON::Serializable
      # Name of the module.
      getter name : String
      # UUID of the module.
      getter uuid : String
      @[JSON::Field(key: "baseAddress")]
      # Base address where the module is loaded into memory. Encoded as a decimal
      # or hexadecimal (0x prefixed) string.
      getter base_address : String
      # Size of the module in bytes.
      getter size : Number::Primitive
    end

    # ----------------------------------------
    # Memory Section: commands
    # ----------------------------------------

    struct GetDOMCounters
      include Protocol::Command
      include JSON::Serializable
      getter documents : Int::Primitive
      getter nodes : Int::Primitive
      @[JSON::Field(key: "jsEventListeners")]
      getter js_event_listeners : Int::Primitive
    end

    struct PrepareForLeakDetection
      include Protocol::Command
      include JSON::Serializable
    end

    # Simulate OomIntervention by purging V8 memory.
    struct ForciblyPurgeJavaScriptMemory
      include Protocol::Command
      include JSON::Serializable
    end

    # Enable/disable suppressing memory pressure notifications in all processes.
    struct SetPressureNotificationsSuppressed
      include Protocol::Command
      include JSON::Serializable
    end

    # Simulate a memory pressure notification in all processes.
    struct SimulatePressureNotification
      include Protocol::Command
      include JSON::Serializable
    end

    # Start collecting native memory profile.
    struct StartSampling
      include Protocol::Command
      include JSON::Serializable
    end

    # Stop collecting native memory profile.
    struct StopSampling
      include Protocol::Command
      include JSON::Serializable
    end

    # Retrieve native memory allocations profile
    # collected since renderer process startup.
    struct GetAllTimeSamplingProfile
      include Protocol::Command
      include JSON::Serializable
      getter profile : SamplingProfile
    end

    # Retrieve native memory allocations profile
    # collected since browser process startup.
    struct GetBrowserSamplingProfile
      include Protocol::Command
      include JSON::Serializable
      getter profile : SamplingProfile
    end

    # Retrieve native memory allocations profile collected since last
    # `startSampling` call.
    struct GetSamplingProfile
      include Protocol::Command
      include JSON::Serializable
      getter profile : SamplingProfile
    end
  end
end
