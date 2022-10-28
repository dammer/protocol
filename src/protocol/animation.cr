# Animation module dependencies
require "./runtime"
require "./dom"

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module Animation
    # ----------------------------------------
    # Animation Section: types
    # ----------------------------------------

    # Animation instance.
    struct Animation
      include JSON::Serializable
      # `Animation`'s id.
      getter id : String
      # `Animation`'s name.
      getter name : String
      @[JSON::Field(key: "pausedState")]
      # `Animation`'s internal paused state.
      getter paused_state : Bool
      @[JSON::Field(key: "playState")]
      # `Animation`'s play state.
      getter play_state : String
      @[JSON::Field(key: "playbackRate")]
      # `Animation`'s playback rate.
      getter playback_rate : Number::Primitive
      @[JSON::Field(key: "startTime")]
      # `Animation`'s start time.
      getter start_time : Number::Primitive
      @[JSON::Field(key: "currentTime")]
      # `Animation`'s current time.
      getter current_time : Number::Primitive
      # Animation type of `Animation`.
      getter type : String
      # `Animation`'s source animation node.
      getter source : AnimationEffect?
      @[JSON::Field(key: "cssId")]
      # A unique ID for `Animation` representing the sources that triggered this CSS
      # animation/transition.
      getter css_id : String?
    end

    # AnimationEffect instance
    struct AnimationEffect
      include JSON::Serializable
      # `AnimationEffect`'s delay.
      getter delay : Number::Primitive
      @[JSON::Field(key: "endDelay")]
      # `AnimationEffect`'s end delay.
      getter end_delay : Number::Primitive
      @[JSON::Field(key: "iterationStart")]
      # `AnimationEffect`'s iteration start.
      getter iteration_start : Number::Primitive
      # `AnimationEffect`'s iterations.
      getter iterations : Number::Primitive
      # `AnimationEffect`'s iteration duration.
      getter duration : Number::Primitive
      # `AnimationEffect`'s playback direction.
      getter direction : String
      # `AnimationEffect`'s fill mode.
      getter fill : String
      @[JSON::Field(key: "backendNodeId")]
      # `AnimationEffect`'s target node.
      getter backend_node_id : DOM::BackendNodeId?
      @[JSON::Field(key: "keyframesRule")]
      # `AnimationEffect`'s keyframes.
      getter keyframes_rule : KeyframesRule?
      # `AnimationEffect`'s timing function.
      getter easing : String
    end

    # Keyframes Rule
    struct KeyframesRule
      include JSON::Serializable
      # CSS keyframed animation's name.
      getter name : String?
      # List of animation keyframes.
      getter keyframes : Array(KeyframeStyle)
    end

    # Keyframe Style
    struct KeyframeStyle
      include JSON::Serializable
      # Keyframe's time offset.
      getter offset : String
      # `AnimationEffect`'s timing function.
      getter easing : String
    end

    # ----------------------------------------
    # Animation Section: commands
    # ----------------------------------------

    # Disables animation domain notifications.
    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    # Enables animation domain notifications.
    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    # Returns the current time of the an animation.
    struct GetCurrentTime
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "currentTime")]
      # Current time of the page.
      getter current_time : Number::Primitive
    end

    # Gets the playback rate of the document timeline.
    struct GetPlaybackRate
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "playbackRate")]
      # Playback rate for animations on page.
      getter playback_rate : Number::Primitive
    end

    # Releases a set of animations to no longer be manipulated.
    struct ReleaseAnimations
      include Protocol::Command
      include JSON::Serializable
    end

    # Gets the remote object of the Animation.
    struct ResolveAnimation
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "remoteObject")]
      # Corresponding remote object.
      getter remote_object : Runtime::RemoteObject
    end

    # Seek a set of animations to a particular time within each animation.
    struct SeekAnimations
      include Protocol::Command
      include JSON::Serializable
    end

    # Sets the paused state of a set of animations.
    struct SetPaused
      include Protocol::Command
      include JSON::Serializable
    end

    # Sets the playback rate of the document timeline.
    struct SetPlaybackRate
      include Protocol::Command
      include JSON::Serializable
    end

    # Sets the timing of an animation node.
    struct SetTiming
      include Protocol::Command
      include JSON::Serializable
    end

    # ----------------------------------------
    # Animation Section: events
    # ----------------------------------------

    # Event for when an animation has been cancelled.
    struct AnimationCanceled
      include JSON::Serializable
      include Protocol::Event
      # Id of the animation that was cancelled.
      getter id : String
    end

    # Event for each animation that has been created.
    struct AnimationCreated
      include JSON::Serializable
      include Protocol::Event
      # Id of the animation that was created.
      getter id : String
    end

    # Event for animation that has been started.
    struct AnimationStarted
      include JSON::Serializable
      include Protocol::Event
      # Animation that was started.
      getter animation : Animation
    end
  end
end
