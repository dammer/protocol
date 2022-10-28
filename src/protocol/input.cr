# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module Input
    # ----------------------------------------
    # Input Section: types
    # ----------------------------------------

    struct TouchPoint
      include JSON::Serializable
      # X coordinate of the event relative to the main frame's viewport in CSS pixels.
      getter x : Number::Primitive
      # Y coordinate of the event relative to the main frame's viewport in CSS pixels. 0 refers to
      # the top of the viewport and Y increases as it proceeds towards the bottom of the viewport.
      getter y : Number::Primitive
      @[JSON::Field(key: "radiusX")]
      # X radius of the touch area (default: 1.0).
      getter radius_x : Number::Primitive?
      @[JSON::Field(key: "radiusY")]
      # Y radius of the touch area (default: 1.0).
      getter radius_y : Number::Primitive?
      @[JSON::Field(key: "rotationAngle")]
      # Rotation angle (default: 0.0).
      getter rotation_angle : Number::Primitive?
      # Force (default: 1.0).
      getter force : Number::Primitive?
      @[JSON::Field(key: "tangentialPressure")]
      # The normalized tangential pressure, which has a range of [-1,1] (default: 0).
      getter tangential_pressure : Number::Primitive?
      @[JSON::Field(key: "tiltX")]
      # The plane angle between the Y-Z plane and the plane containing both the stylus axis and the Y axis, in degrees of the range [-90,90], a positive tiltX is to the right (default: 0)
      getter tilt_x : Int::Primitive?
      @[JSON::Field(key: "tiltY")]
      # The plane angle between the X-Z plane and the plane containing both the stylus axis and the X axis, in degrees of the range [-90,90], a positive tiltY is towards the user (default: 0).
      getter tilt_y : Int::Primitive?
      # The clockwise rotation of a pen stylus around its own major axis, in degrees in the range [0,359] (default: 0).
      getter twist : Int::Primitive?
      # Identifier used to track touch sources between events, must be unique within an event.
      getter id : Number::Primitive?
    end

    enum GestureSourceType
      Default # default
      Touch   # touch
      Mouse   # mouse
    end

    enum MouseButton
      None    # none
      Left    # left
      Middle  # middle
      Right   # right
      Back    # back
      Forward # forward
    end

    # UTC time in seconds, counted from January 1, 1970.
    alias TimeSinceEpoch = Number::Primitive

    struct DragDataItem
      include JSON::Serializable
      @[JSON::Field(key: "mimeType")]
      # Mime type of the dragged data.
      getter mime_type : String
      # Depending of the value of `mimeType`, it contains the dragged link,
      # text, HTML markup or any other data.
      getter data : String
      # Title associated with a link. Only valid when `mimeType` == "text/uri-list".
      getter title : String?
      @[JSON::Field(key: "baseURL")]
      # Stores the base URL for the contained markup. Only valid when `mimeType`
      # == "text/html".
      getter base_url : String?
    end

    struct DragData
      include JSON::Serializable
      getter items : Array(DragDataItem)
      # List of filenames that should be included when dropping
      getter files : Array(String)?
      @[JSON::Field(key: "dragOperationsMask")]
      # Bit field representing allowed drag operations. Copy = 1, Link = 2, Move = 16
      getter drag_operations_mask : Int::Primitive
    end

    # ----------------------------------------
    # Input Section: commands
    # ----------------------------------------

    # Dispatches a drag event into the page.
    struct DispatchDragEvent
      include Protocol::Command
      include JSON::Serializable
    end

    # Dispatches a key event to the page.
    struct DispatchKeyEvent
      include Protocol::Command
      include JSON::Serializable
    end

    # This method emulates inserting text that doesn't come from a key press,
    # for example an emoji keyboard or an IME.
    struct InsertText
      include Protocol::Command
      include JSON::Serializable
    end

    # This method sets the current candidate text for ime.
    # Use imeCommitComposition to commit the final text.
    # Use imeSetComposition with empty string as text to cancel composition.
    struct ImeSetComposition
      include Protocol::Command
      include JSON::Serializable
    end

    # Dispatches a mouse event to the page.
    struct DispatchMouseEvent
      include Protocol::Command
      include JSON::Serializable
    end

    # Dispatches a touch event to the page.
    struct DispatchTouchEvent
      include Protocol::Command
      include JSON::Serializable
    end

    # Emulates touch event from the mouse event parameters.
    struct EmulateTouchFromMouseEvent
      include Protocol::Command
      include JSON::Serializable
    end

    # Ignores input events (useful while auditing page).
    struct SetIgnoreInputEvents
      include Protocol::Command
      include JSON::Serializable
    end

    # Prevents default drag and drop behavior and instead emits `Input.dragIntercepted` events.
    # Drag and drop behavior can be directly controlled via `Input.dispatchDragEvent`.
    struct SetInterceptDrags
      include Protocol::Command
      include JSON::Serializable
    end

    # Synthesizes a pinch gesture over a time period by issuing appropriate touch events.
    struct SynthesizePinchGesture
      include Protocol::Command
      include JSON::Serializable
    end

    # Synthesizes a scroll gesture over a time period by issuing appropriate touch events.
    struct SynthesizeScrollGesture
      include Protocol::Command
      include JSON::Serializable
    end

    # Synthesizes a tap gesture over a time period by issuing appropriate touch events.
    struct SynthesizeTapGesture
      include Protocol::Command
      include JSON::Serializable
    end

    # ----------------------------------------
    # Input Section: events
    # ----------------------------------------

    # Emitted only when `Input.setInterceptDrags` is enabled. Use this data with `Input.dispatchDragEvent` to
    # restore normal drag and drop behavior.
    struct DragIntercepted
      include JSON::Serializable
      include Protocol::Event
      getter data : DragData
    end
  end
end
