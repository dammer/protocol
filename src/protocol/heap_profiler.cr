# HeapProfiler module dependencies
require "./runtime"

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module HeapProfiler
    # ----------------------------------------
    # HeapProfiler Section: types
    # ----------------------------------------

    # Heap snapshot object id.
    alias HeapSnapshotObjectId = String

    # Sampling Heap Profile node. Holds callsite information, allocation statistics and child nodes.
    struct SamplingHeapProfileNode
      include JSON::Serializable
      @[JSON::Field(key: "callFrame")]
      # Function location.
      getter call_frame : Runtime::CallFrame
      @[JSON::Field(key: "selfSize")]
      # Allocations size in bytes for the node excluding children.
      getter self_size : Number::Primitive
      # Node id. Ids are unique across all profiles collected between startSampling and stopSampling.
      getter id : Int::Primitive
      # Child nodes.
      getter children : Array(SamplingHeapProfileNode)
    end

    # A single sample from a sampling profile.
    struct SamplingHeapProfileSample
      include JSON::Serializable
      # Allocation size in bytes attributed to the sample.
      getter size : Number::Primitive
      @[JSON::Field(key: "nodeId")]
      # Id of the corresponding profile tree node.
      getter node_id : Int::Primitive
      # Time-ordered sample ordinal number. It is unique across all profiles retrieved
      # between startSampling and stopSampling.
      getter ordinal : Number::Primitive
    end

    # Sampling profile.
    struct SamplingHeapProfile
      include JSON::Serializable
      getter head : SamplingHeapProfileNode
      getter samples : Array(SamplingHeapProfileSample)
    end

    # ----------------------------------------
    # HeapProfiler Section: commands
    # ----------------------------------------

    # Enables console to refer to the node with given id via $x (see Command Line API for more details
    # $x functions).
    struct AddInspectedHeapObject
      include Protocol::Command
      include JSON::Serializable
    end

    struct CollectGarbage
      include Protocol::Command
      include JSON::Serializable
    end

    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    struct GetHeapObjectId
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "heapSnapshotObjectId")]
      # Id of the heap snapshot object corresponding to the passed remote object id.
      getter heap_snapshot_object_id : HeapSnapshotObjectId
    end

    struct GetObjectByHeapObjectId
      include Protocol::Command
      include JSON::Serializable
      # Evaluation result.
      getter result : Runtime::RemoteObject
    end

    struct GetSamplingProfile
      include Protocol::Command
      include JSON::Serializable
      # Return the sampling profile being collected.
      getter profile : SamplingHeapProfile
    end

    struct StartSampling
      include Protocol::Command
      include JSON::Serializable
    end

    struct StartTrackingHeapObjects
      include Protocol::Command
      include JSON::Serializable
    end

    struct StopSampling
      include Protocol::Command
      include JSON::Serializable
      # Recorded sampling heap profile.
      getter profile : SamplingHeapProfile
    end

    struct StopTrackingHeapObjects
      include Protocol::Command
      include JSON::Serializable
    end

    struct TakeHeapSnapshot
      include Protocol::Command
      include JSON::Serializable
    end

    # ----------------------------------------
    # HeapProfiler Section: events
    # ----------------------------------------

    struct AddHeapSnapshotChunk
      include JSON::Serializable
      include Protocol::Event
      getter chunk : String
    end

    # If heap objects tracking has been started then backend may send update for one or more fragments
    struct HeapStatsUpdate
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "statsUpdate")]
      # An array of triplets. Each triplet describes a fragment. The first integer is the fragment
      # index, the second integer is a total count of objects for the fragment, the third integer is
      # a total size of the objects for the fragment.
      getter stats_update : Array(Int::Primitive)
    end

    # If heap objects tracking has been started then backend regularly sends a current value for last
    # seen object id and corresponding timestamp. If the were changes in the heap since last event
    # then one or more heapStatsUpdate events will be sent before a new lastSeenObjectId event.
    struct LastSeenObjectId
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "lastSeenObjectId")]
      getter last_seen_object_id : Int::Primitive
      getter timestamp : Number::Primitive
    end

    struct ReportHeapSnapshotProgress
      include JSON::Serializable
      include Protocol::Event
      getter done : Int::Primitive
      getter total : Int::Primitive
      getter finished : Bool?
    end

    struct ResetProfiles
      include JSON::Serializable
      include Protocol::Event
    end
  end
end
