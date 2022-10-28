# =========================================================
# This domain emulates different environments for the page.
# =========================================================

# Emulation module dependencies
require "./dom"
require "./page"
require "./runtime"

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module Emulation
    # ----------------------------------------
    # Emulation Section: types
    # ----------------------------------------

    # Screen orientation.
    struct ScreenOrientation
      include JSON::Serializable
      # Orientation type.
      getter type : String
      # Orientation angle.
      getter angle : Int::Primitive
    end

    struct DisplayFeature
      include JSON::Serializable
      # Orientation of a display feature in relation to screen
      getter orientation : String
      # The offset from the screen origin in either the x (for vertical
      # orientation) or y (for horizontal orientation) direction.
      getter offset : Int::Primitive
      @[JSON::Field(key: "maskLength")]
      # A display feature may mask content such that it is not physically
      # displayed - this length along with the offset describes this area.
      # A display feature that only splits content will have a 0 mask_length.
      getter mask_length : Int::Primitive
    end

    struct MediaFeature
      include JSON::Serializable
      getter name : String
      getter value : String
    end

    # advance: If the scheduler runs out of immediate work, the virtual time base may fast forward to
    # allow the next delayed task (if any) to run; pause: The virtual time base may not advance;
    # pauseIfNetworkFetchesPending: The virtual time base may not advance if there are any pending
    # resource fetches.
    enum VirtualTimePolicy
      Advance                      # advance
      Pause                        # pause
      PauseIfNetworkFetchesPending # pauseIfNetworkFetchesPending
    end

    # Used to specify User Agent Cient Hints to emulate. See https://wicg.github.io/ua-client-hints
    struct UserAgentBrandVersion
      include JSON::Serializable
      getter brand : String
      getter version : String
    end

    # Used to specify User Agent Cient Hints to emulate. See https://wicg.github.io/ua-client-hints
    # Missing optional values will be filled in by the target with what it would normally use.
    struct UserAgentMetadata
      include JSON::Serializable
      getter brands : Array(UserAgentBrandVersion)?
      @[JSON::Field(key: "fullVersionList")]
      getter full_version_list : Array(UserAgentBrandVersion)?
      @[JSON::Field(key: "fullVersion")]
      getter full_version : String?
      getter platform : String
      @[JSON::Field(key: "platformVersion")]
      getter platform_version : String
      getter architecture : String
      getter model : String
      getter mobile : Bool
      getter bitness : String?
      getter wow64 : Bool?
    end

    # Enum of image types that can be disabled.
    enum DisabledImageType
      Avif # avif
      Jxl  # jxl
      Webp # webp
    end

    # ----------------------------------------
    # Emulation Section: commands
    # ----------------------------------------

    # Tells whether emulation is supported.
    struct CanEmulate
      include Protocol::Command
      include JSON::Serializable
      # True if emulation is supported.
      getter result : Bool
    end

    # Clears the overridden device metrics.
    struct ClearDeviceMetricsOverride
      include Protocol::Command
      include JSON::Serializable
    end

    # Clears the overridden Geolocation Position and Error.
    struct ClearGeolocationOverride
      include Protocol::Command
      include JSON::Serializable
    end

    # Requests that page scale factor is reset to initial values.
    struct ResetPageScaleFactor
      include Protocol::Command
      include JSON::Serializable
    end

    # Enables or disables simulating a focused and active page.
    struct SetFocusEmulationEnabled
      include Protocol::Command
      include JSON::Serializable
    end

    # Automatically render all web contents using a dark theme.
    struct SetAutoDarkModeOverride
      include Protocol::Command
      include JSON::Serializable
    end

    # Enables CPU throttling to emulate slow CPUs.
    struct SetCPUThrottlingRate
      include Protocol::Command
      include JSON::Serializable
    end

    # Sets or clears an override of the default background color of the frame. This override is used
    # if the content does not specify one.
    struct SetDefaultBackgroundColorOverride
      include Protocol::Command
      include JSON::Serializable
    end

    # Overrides the values of device screen dimensions (window.screen.width, window.screen.height,
    # window.innerWidth, window.innerHeight, and "device-width"/"device-height"-related CSS media
    # query results).
    struct SetDeviceMetricsOverride
      include Protocol::Command
      include JSON::Serializable
    end

    struct SetScrollbarsHidden
      include Protocol::Command
      include JSON::Serializable
    end

    struct SetDocumentCookieDisabled
      include Protocol::Command
      include JSON::Serializable
    end

    struct SetEmitTouchEventsForMouse
      include Protocol::Command
      include JSON::Serializable
    end

    # Emulates the given media type or media feature for CSS media queries.
    struct SetEmulatedMedia
      include Protocol::Command
      include JSON::Serializable
    end

    # Emulates the given vision deficiency.
    struct SetEmulatedVisionDeficiency
      include Protocol::Command
      include JSON::Serializable
    end

    # Overrides the Geolocation Position or Error. Omitting any of the parameters emulates position
    # unavailable.
    struct SetGeolocationOverride
      include Protocol::Command
      include JSON::Serializable
    end

    # Overrides the Idle state.
    struct SetIdleOverride
      include Protocol::Command
      include JSON::Serializable
    end

    # Clears Idle state overrides.
    struct ClearIdleOverride
      include Protocol::Command
      include JSON::Serializable
    end

    # Overrides value returned by the javascript navigator object.
    struct SetNavigatorOverrides
      include Protocol::Command
      include JSON::Serializable
    end

    # Sets a specified page scale factor.
    struct SetPageScaleFactor
      include Protocol::Command
      include JSON::Serializable
    end

    # Switches script execution in the page.
    struct SetScriptExecutionDisabled
      include Protocol::Command
      include JSON::Serializable
    end

    # Enables touch on platforms which do not support them.
    struct SetTouchEmulationEnabled
      include Protocol::Command
      include JSON::Serializable
    end

    # Turns on virtual time for all frames (replacing real-time with a synthetic time source) and sets
    # the current virtual time policy.  Note this supersedes any previous time budget.
    struct SetVirtualTimePolicy
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "virtualTimeTicksBase")]
      # Absolute timestamp at which virtual time was first enabled (up time in milliseconds).
      getter virtual_time_ticks_base : Number::Primitive
    end

    # Overrides default host system locale with the specified one.
    struct SetLocaleOverride
      include Protocol::Command
      include JSON::Serializable
    end

    # Overrides default host system timezone with the specified one.
    struct SetTimezoneOverride
      include Protocol::Command
      include JSON::Serializable
    end

    # Resizes the frame/viewport of the page. Note that this does not affect the frame's container
    # (e.g. browser window). Can be used to produce screenshots of the specified size. Not supported
    # on Android.
    struct SetVisibleSize
      include Protocol::Command
      include JSON::Serializable
    end

    struct SetDisabledImageTypes
      include Protocol::Command
      include JSON::Serializable
    end

    struct SetHardwareConcurrencyOverride
      include Protocol::Command
      include JSON::Serializable
    end

    # Allows overriding user agent with the given string.
    struct SetUserAgentOverride
      include Protocol::Command
      include JSON::Serializable
    end

    # Allows overriding the automation flag.
    struct SetAutomationOverride
      include Protocol::Command
      include JSON::Serializable
    end

    # ----------------------------------------
    # Emulation Section: events
    # ----------------------------------------

    # Notification sent after the virtual time budget for the current VirtualTimePolicy has run out.
    struct VirtualTimeBudgetExpired
      include JSON::Serializable
      include Protocol::Event
    end
  end
end
