# ===============================================
# This domain allows inspection of Web Audio API.
# https://webaudio.github.io/web-audio-api/
# ===============================================

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module WebAudio
    # ----------------------------------------
    # WebAudio Section: types
    # ----------------------------------------

    # An unique ID for a graph object (AudioContext, AudioNode, AudioParam) in Web Audio API
    alias GraphObjectId = String

    # Enum of BaseAudioContext types
    enum ContextType
      Realtime # realtime
      Offline  # offline
    end

    # Enum of AudioContextState from the spec
    enum ContextState
      Suspended # suspended
      Running   # running
      Closed    # closed
    end

    # Enum of AudioNode types
    alias NodeType = String

    # Enum of AudioNode::ChannelCountMode from the spec
    @[DashEnum]
    enum ChannelCountMode
      ClampedMax # clamped-max
      Explicit   # explicit
      Max        # max
    end

    # Enum of AudioNode::ChannelInterpretation from the spec
    enum ChannelInterpretation
      Discrete # discrete
      Speakers # speakers
    end

    # Enum of AudioParam types
    alias ParamType = String

    # Enum of AudioParam::AutomationRate from the spec
    @[DashEnum]
    enum AutomationRate
      ARate # a-rate
      KRate # k-rate
    end

    # Fields in AudioContext that change in real-time.
    struct ContextRealtimeData
      include JSON::Serializable
      @[JSON::Field(key: "currentTime")]
      # The current context time in second in BaseAudioContext.
      getter current_time : Number::Primitive
      @[JSON::Field(key: "renderCapacity")]
      # The time spent on rendering graph divided by render quantum duration,
      # and multiplied by 100. 100 means the audio renderer reached the full
      # capacity and glitch may occur.
      getter render_capacity : Number::Primitive
      @[JSON::Field(key: "callbackIntervalMean")]
      # A running mean of callback interval.
      getter callback_interval_mean : Number::Primitive
      @[JSON::Field(key: "callbackIntervalVariance")]
      # A running variance of callback interval.
      getter callback_interval_variance : Number::Primitive
    end

    # Protocol object for BaseAudioContext
    struct BaseAudioContext
      include JSON::Serializable
      @[JSON::Field(key: "contextId")]
      getter context_id : GraphObjectId
      @[JSON::Field(key: "contextType")]
      getter context_type : ContextType
      @[JSON::Field(key: "contextState")]
      getter context_state : ContextState
      @[JSON::Field(key: "realtimeData")]
      getter realtime_data : ContextRealtimeData?
      @[JSON::Field(key: "callbackBufferSize")]
      # Platform-dependent callback buffer size.
      getter callback_buffer_size : Number::Primitive
      @[JSON::Field(key: "maxOutputChannelCount")]
      # Number of output channels supported by audio hardware in use.
      getter max_output_channel_count : Number::Primitive
      @[JSON::Field(key: "sampleRate")]
      # Context sample rate.
      getter sample_rate : Number::Primitive
    end

    # Protocol object for AudioListener
    struct AudioListener
      include JSON::Serializable
      @[JSON::Field(key: "listenerId")]
      getter listener_id : GraphObjectId
      @[JSON::Field(key: "contextId")]
      getter context_id : GraphObjectId
    end

    # Protocol object for AudioNode
    struct AudioNode
      include JSON::Serializable
      @[JSON::Field(key: "nodeId")]
      getter node_id : GraphObjectId
      @[JSON::Field(key: "contextId")]
      getter context_id : GraphObjectId
      @[JSON::Field(key: "nodeType")]
      getter node_type : NodeType
      @[JSON::Field(key: "numberOfInputs")]
      getter number_of_inputs : Number::Primitive
      @[JSON::Field(key: "numberOfOutputs")]
      getter number_of_outputs : Number::Primitive
      @[JSON::Field(key: "channelCount")]
      getter channel_count : Number::Primitive
      @[JSON::Field(key: "channelCountMode")]
      getter channel_count_mode : ChannelCountMode
      @[JSON::Field(key: "channelInterpretation")]
      getter channel_interpretation : ChannelInterpretation
    end

    # Protocol object for AudioParam
    struct AudioParam
      include JSON::Serializable
      @[JSON::Field(key: "paramId")]
      getter param_id : GraphObjectId
      @[JSON::Field(key: "nodeId")]
      getter node_id : GraphObjectId
      @[JSON::Field(key: "contextId")]
      getter context_id : GraphObjectId
      @[JSON::Field(key: "paramType")]
      getter param_type : ParamType
      getter rate : AutomationRate
      @[JSON::Field(key: "defaultValue")]
      getter default_value : Number::Primitive
      @[JSON::Field(key: "minValue")]
      getter min_value : Number::Primitive
      @[JSON::Field(key: "maxValue")]
      getter max_value : Number::Primitive
    end

    # ----------------------------------------
    # WebAudio Section: commands
    # ----------------------------------------

    # Enables the WebAudio domain and starts sending context lifetime events.
    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    # Disables the WebAudio domain.
    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    # Fetch the realtime data from the registered contexts.
    struct GetRealtimeData
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "realtimeData")]
      getter realtime_data : ContextRealtimeData
    end

    # ----------------------------------------
    # WebAudio Section: events
    # ----------------------------------------

    # Notifies that a new BaseAudioContext has been created.
    struct ContextCreated
      include JSON::Serializable
      include Protocol::Event
      getter context : BaseAudioContext
    end

    # Notifies that an existing BaseAudioContext will be destroyed.
    struct ContextWillBeDestroyed
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "contextId")]
      getter context_id : GraphObjectId
    end

    # Notifies that existing BaseAudioContext has changed some properties (id stays the same)..
    struct ContextChanged
      include JSON::Serializable
      include Protocol::Event
      getter context : BaseAudioContext
    end

    # Notifies that the construction of an AudioListener has finished.
    struct AudioListenerCreated
      include JSON::Serializable
      include Protocol::Event
      getter listener : AudioListener
    end

    # Notifies that a new AudioListener has been created.
    struct AudioListenerWillBeDestroyed
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "contextId")]
      getter context_id : GraphObjectId
      @[JSON::Field(key: "listenerId")]
      getter listener_id : GraphObjectId
    end

    # Notifies that a new AudioNode has been created.
    struct AudioNodeCreated
      include JSON::Serializable
      include Protocol::Event
      getter node : AudioNode
    end

    # Notifies that an existing AudioNode has been destroyed.
    struct AudioNodeWillBeDestroyed
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "contextId")]
      getter context_id : GraphObjectId
      @[JSON::Field(key: "nodeId")]
      getter node_id : GraphObjectId
    end

    # Notifies that a new AudioParam has been created.
    struct AudioParamCreated
      include JSON::Serializable
      include Protocol::Event
      getter param : AudioParam
    end

    # Notifies that an existing AudioParam has been destroyed.
    struct AudioParamWillBeDestroyed
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "contextId")]
      getter context_id : GraphObjectId
      @[JSON::Field(key: "nodeId")]
      getter node_id : GraphObjectId
      @[JSON::Field(key: "paramId")]
      getter param_id : GraphObjectId
    end

    # Notifies that two AudioNodes are connected.
    struct NodesConnected
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "contextId")]
      getter context_id : GraphObjectId
      @[JSON::Field(key: "sourceId")]
      getter source_id : GraphObjectId
      @[JSON::Field(key: "destinationId")]
      getter destination_id : GraphObjectId
      @[JSON::Field(key: "sourceOutputIndex")]
      getter source_output_index : Number::Primitive?
      @[JSON::Field(key: "destinationInputIndex")]
      getter destination_input_index : Number::Primitive?
    end

    # Notifies that AudioNodes are disconnected. The destination can be null, and it means all the outgoing connections from the source are disconnected.
    struct NodesDisconnected
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "contextId")]
      getter context_id : GraphObjectId
      @[JSON::Field(key: "sourceId")]
      getter source_id : GraphObjectId
      @[JSON::Field(key: "destinationId")]
      getter destination_id : GraphObjectId
      @[JSON::Field(key: "sourceOutputIndex")]
      getter source_output_index : Number::Primitive?
      @[JSON::Field(key: "destinationInputIndex")]
      getter destination_input_index : Number::Primitive?
    end

    # Notifies that an AudioNode is connected to an AudioParam.
    struct NodeParamConnected
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "contextId")]
      getter context_id : GraphObjectId
      @[JSON::Field(key: "sourceId")]
      getter source_id : GraphObjectId
      @[JSON::Field(key: "destinationId")]
      getter destination_id : GraphObjectId
      @[JSON::Field(key: "sourceOutputIndex")]
      getter source_output_index : Number::Primitive?
    end

    # Notifies that an AudioNode is disconnected to an AudioParam.
    struct NodeParamDisconnected
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "contextId")]
      getter context_id : GraphObjectId
      @[JSON::Field(key: "sourceId")]
      getter source_id : GraphObjectId
      @[JSON::Field(key: "destinationId")]
      getter destination_id : GraphObjectId
      @[JSON::Field(key: "sourceOutputIndex")]
      getter source_output_index : Number::Primitive?
    end
  end
end
