# ====================================================================
# Reporting of performance timeline events, as specified in
# https://w3c.github.io/performance-timeline/#dom-performanceobserver.
# ====================================================================

# PerformanceTimeline module dependencies
require "./dom"
require "./network"

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module PerformanceTimeline
    # ----------------------------------------
    # PerformanceTimeline Section: types
    # ----------------------------------------

    # See https://github.com/WICG/LargestContentfulPaint and largest_contentful_paint.idl
    struct LargestContentfulPaint
      include JSON::Serializable
      @[JSON::Field(key: "renderTime")]
      getter render_time : Network::TimeSinceEpoch
      @[JSON::Field(key: "loadTime")]
      getter load_time : Network::TimeSinceEpoch
      # The number of pixels being painted.
      getter size : Number::Primitive
      @[JSON::Field(key: "elementId")]
      # The id attribute of the element, if available.
      getter element_id : String?
      # The URL of the image (may be trimmed).
      getter url : String?
      @[JSON::Field(key: "nodeId")]
      getter node_id : DOM::BackendNodeId?
    end

    struct LayoutShiftAttribution
      include JSON::Serializable
      @[JSON::Field(key: "previousRect")]
      getter previous_rect : DOM::Rect
      @[JSON::Field(key: "currentRect")]
      getter current_rect : DOM::Rect
      @[JSON::Field(key: "nodeId")]
      getter node_id : DOM::BackendNodeId?
    end

    # See https://wicg.github.io/layout-instability/#sec-layout-shift and layout_shift.idl
    struct LayoutShift
      include JSON::Serializable
      # Score increment produced by this event.
      getter value : Number::Primitive
      @[JSON::Field(key: "hadRecentInput")]
      getter had_recent_input : Bool
      @[JSON::Field(key: "lastInputTime")]
      getter last_input_time : Network::TimeSinceEpoch
      getter sources : Array(LayoutShiftAttribution)
    end

    struct TimelineEvent
      include JSON::Serializable
      @[JSON::Field(key: "frameId")]
      # Identifies the frame that this event is related to. Empty for non-frame targets.
      getter frame_id : Page::FrameId
      # The event type, as specified in https://w3c.github.io/performance-timeline/#dom-performanceentry-entrytype
      # This determines which of the optional "details" fiedls is present.
      getter type : String
      # Name may be empty depending on the type.
      getter name : String
      # Time in seconds since Epoch, monotonically increasing within document lifetime.
      getter time : Network::TimeSinceEpoch
      # Event duration, if applicable.
      getter duration : Number::Primitive?
      @[JSON::Field(key: "lcpDetails")]
      getter lcp_details : LargestContentfulPaint?
      @[JSON::Field(key: "layoutShiftDetails")]
      getter layout_shift_details : LayoutShift?
    end

    # ----------------------------------------
    # PerformanceTimeline Section: commands
    # ----------------------------------------

    # Previously buffered events would be reported before method returns.
    # See also: timelineEventAdded
    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    # ----------------------------------------
    # PerformanceTimeline Section: events
    # ----------------------------------------

    # Sent when a performance timeline event is added. See reportPerformanceTimeline method.
    struct TimelineEventAdded
      include JSON::Serializable
      include Protocol::Event
      getter event : TimelineEvent
    end
  end
end
