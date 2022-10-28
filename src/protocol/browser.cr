# ===================================================================
# The Browser domain defines methods and events for browser managing.
# ===================================================================

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module Browser
    # ----------------------------------------
    # Browser Section: types
    # ----------------------------------------

    alias BrowserContextID = String

    alias WindowID = Int::Primitive

    # The state of the browser window.
    enum WindowState
      Normal     # normal
      Minimized  # minimized
      Maximized  # maximized
      Fullscreen # fullscreen
    end

    # Browser window bounds information
    struct Bounds
      include JSON::Serializable
      # The offset from the left edge of the screen to the window in pixels.
      getter left : Int::Primitive?
      # The offset from the top edge of the screen to the window in pixels.
      getter top : Int::Primitive?
      # The window width in pixels.
      getter width : Int::Primitive?
      # The window height in pixels.
      getter height : Int::Primitive?
      @[JSON::Field(key: "windowState")]
      # The window state. Default to normal.
      getter window_state : WindowState?
    end

    enum PermissionType
      AccessibilityEvents      # accessibilityEvents
      AudioCapture             # audioCapture
      BackgroundSync           # backgroundSync
      BackgroundFetch          # backgroundFetch
      ClipboardReadWrite       # clipboardReadWrite
      ClipboardSanitizedWrite  # clipboardSanitizedWrite
      DisplayCapture           # displayCapture
      DurableStorage           # durableStorage
      Flash                    # flash
      Geolocation              # geolocation
      Midi                     # midi
      MidiSysex                # midiSysex
      Nfc                      # nfc
      Notifications            # notifications
      PaymentHandler           # paymentHandler
      PeriodicBackgroundSync   # periodicBackgroundSync
      ProtectedMediaIdentifier # protectedMediaIdentifier
      Sensors                  # sensors
      VideoCapture             # videoCapture
      VideoCapturePanTiltZoom  # videoCapturePanTiltZoom
      IdleDetection            # idleDetection
      WakeLockScreen           # wakeLockScreen
      WakeLockSystem           # wakeLockSystem
    end

    enum PermissionSetting
      Granted # granted
      Denied  # denied
      Prompt  # prompt
    end

    # Definition of PermissionDescriptor defined in the Permissions API:
    # https://w3c.github.io/permissions/#dictdef-permissiondescriptor.
    struct PermissionDescriptor
      include JSON::Serializable
      # Name of permission.
      # See https://cs.chromium.org/chromium/src/third_party/blink/renderer/modules/permissions/permission_descriptor.idl for valid permission names.
      getter name : String
      # For "midi" permission, may also specify sysex control.
      getter sysex : Bool?
      @[JSON::Field(key: "userVisibleOnly")]
      # For "push" permission, may specify userVisibleOnly.
      # Note that userVisibleOnly = true is the only currently supported type.
      getter user_visible_only : Bool?
      @[JSON::Field(key: "allowWithoutSanitization")]
      # For "clipboard" permission, may specify allowWithoutSanitization.
      getter allow_without_sanitization : Bool?
      @[JSON::Field(key: "panTiltZoom")]
      # For "camera" permission, may specify panTiltZoom.
      getter pan_tilt_zoom : Bool?
    end

    # Browser command ids used by executeBrowserCommand.
    enum BrowserCommandId
      OpenTabSearch  # openTabSearch
      CloseTabSearch # closeTabSearch
    end

    # Chrome histogram bucket.
    struct Bucket
      include JSON::Serializable
      # Minimum value (inclusive).
      getter low : Int::Primitive
      # Maximum value (exclusive).
      getter high : Int::Primitive
      # Number of samples.
      getter count : Int::Primitive
    end

    # Chrome histogram.
    struct Histogram
      include JSON::Serializable
      # Name.
      getter name : String
      # Sum of sample values.
      getter sum : Int::Primitive
      # Total number of samples.
      getter count : Int::Primitive
      # Buckets.
      getter buckets : Array(Bucket)
    end

    # ----------------------------------------
    # Browser Section: commands
    # ----------------------------------------

    # Set permission settings for given origin.
    struct SetPermission
      include Protocol::Command
      include JSON::Serializable
    end

    # Grant specific permissions to the given origin and reject all others.
    struct GrantPermissions
      include Protocol::Command
      include JSON::Serializable
    end

    # Reset all permission management for all origins.
    struct ResetPermissions
      include Protocol::Command
      include JSON::Serializable
    end

    # Set the behavior when downloading a file.
    struct SetDownloadBehavior
      include Protocol::Command
      include JSON::Serializable
    end

    # Cancel a download if in progress
    struct CancelDownload
      include Protocol::Command
      include JSON::Serializable
    end

    # Close browser gracefully.
    struct Close
      include Protocol::Command
      include JSON::Serializable
    end

    # Crashes browser on the main thread.
    struct Crash
      include Protocol::Command
      include JSON::Serializable
    end

    # Crashes GPU process.
    struct CrashGpuProcess
      include Protocol::Command
      include JSON::Serializable
    end

    # Returns version information.
    struct GetVersion
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "protocolVersion")]
      # Protocol version.
      getter protocol_version : String
      # Product name.
      getter product : String
      # Product revision.
      getter revision : String
      @[JSON::Field(key: "userAgent")]
      # User-Agent.
      getter user_agent : String
      @[JSON::Field(key: "jsVersion")]
      # V8 version.
      getter js_version : String
    end

    # Returns the command line switches for the browser process if, and only if
    # --enable-automation is on the commandline.
    struct GetBrowserCommandLine
      include Protocol::Command
      include JSON::Serializable
      # Commandline parameters
      getter arguments : Array(String)
    end

    # Get Chrome histograms.
    struct GetHistograms
      include Protocol::Command
      include JSON::Serializable
      # Histograms.
      getter histograms : Array(Histogram)
    end

    # Get a Chrome histogram by name.
    struct GetHistogram
      include Protocol::Command
      include JSON::Serializable
      # Histogram.
      getter histogram : Histogram
    end

    # Get position and size of the browser window.
    struct GetWindowBounds
      include Protocol::Command
      include JSON::Serializable
      # Bounds information of the window. When window state is 'minimized', the restored window
      # position and size are returned.
      getter bounds : Bounds
    end

    # Get the browser window that contains the devtools target.
    struct GetWindowForTarget
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "windowId")]
      # Browser window id.
      getter window_id : WindowID
      # Bounds information of the window. When window state is 'minimized', the restored window
      # position and size are returned.
      getter bounds : Bounds
    end

    # Set position and/or size of the browser window.
    struct SetWindowBounds
      include Protocol::Command
      include JSON::Serializable
    end

    # Set dock tile details, platform-specific.
    struct SetDockTile
      include Protocol::Command
      include JSON::Serializable
    end

    # Invoke custom browser commands used by telemetry.
    struct ExecuteBrowserCommand
      include Protocol::Command
      include JSON::Serializable
    end

    # ----------------------------------------
    # Browser Section: events
    # ----------------------------------------

    # Fired when page is about to start a download.
    struct DownloadWillBegin
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "frameId")]
      # Id of the frame that caused the download to begin.
      getter frame_id : Page::FrameId
      # Global unique identifier of the download.
      getter guid : String
      # URL of the resource being downloaded.
      getter url : String
      @[JSON::Field(key: "suggestedFilename")]
      # Suggested file name of the resource (the actual name of the file saved on disk may differ).
      getter suggested_filename : String
    end

    # Fired when download makes progress. Last call has |done| == true.
    struct DownloadProgress
      include JSON::Serializable
      include Protocol::Event
      # Global unique identifier of the download.
      getter guid : String
      @[JSON::Field(key: "totalBytes")]
      # Total expected bytes to download.
      getter total_bytes : Number::Primitive
      @[JSON::Field(key: "receivedBytes")]
      # Total bytes received.
      getter received_bytes : Number::Primitive
      # Download status.
      getter state : String
    end
  end
end
