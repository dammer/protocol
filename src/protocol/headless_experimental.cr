# ===========================================================================
# This domain provides experimental commands only supported in headless mode.
# ===========================================================================

# HeadlessExperimental module dependencies
require "./page"
require "./runtime"

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module HeadlessExperimental
    # ----------------------------------------
    # HeadlessExperimental Section: types
    # ----------------------------------------

    # Encoding options for a screenshot.
    struct ScreenshotParams
      include JSON::Serializable
      # Image compression format (defaults to png).
      getter format : String?
      # Compression quality from range [0..100] (jpeg only).
      getter quality : Int::Primitive?
      @[JSON::Field(key: "optimizeForSpeed")]
      # Optimize image encoding for speed, not for resulting size (defaults to false)
      getter optimize_for_speed : Bool?
    end

    # ----------------------------------------
    # HeadlessExperimental Section: commands
    # ----------------------------------------

    # Sends a BeginFrame to the target and returns when the frame was completed. Optionally captures a
    # screenshot from the resulting frame. Requires that the target was created with enabled
    # BeginFrameControl. Designed for use with --run-all-compositor-stages-before-draw, see also
    # https://goo.gle/chrome-headless-rendering for more background.
    struct BeginFrame
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "hasDamage")]
      # Whether the BeginFrame resulted in damage and, thus, a new frame was committed to the
      # display. Reported for diagnostic uses, may be removed in the future.
      getter has_damage : Bool
      @[JSON::Field(key: "screenshotData")]
      # Base64-encoded image data of the screenshot, if one was requested and successfully taken. (Encoded as a base64 string when passed over JSON)
      getter screenshot_data : String?
    end

    # Disables headless events for the target.
    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    # Enables headless events for the target.
    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    # ----------------------------------------
    # HeadlessExperimental Section: events
    # ----------------------------------------

    # Issued when the target starts or stops needing BeginFrames.
    # Deprecated. Issue beginFrame unconditionally instead and use result from
    # beginFrame to detect whether the frames were suppressed.
    struct NeedsBeginFramesChanged
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "needsBeginFrames")]
      # True if BeginFrames are needed, false otherwise.
      getter needs_begin_frames : Bool
    end
  end
end
