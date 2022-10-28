# ===================================================================
# Supports additional targets discovery and allows to attach to them.
# ===================================================================

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module Target
    # ----------------------------------------
    # Target Section: types
    # ----------------------------------------

    alias TargetID = String

    # Unique identifier of attached debugging session.
    alias SessionID = String

    struct TargetInfo
      include JSON::Serializable
      @[JSON::Field(key: "targetId")]
      getter target_id : TargetID
      getter type : String
      getter title : String
      getter url : String
      # Whether the target has an attached client.
      getter attached : Bool
      @[JSON::Field(key: "openerId")]
      # Opener target Id
      getter opener_id : TargetID?
      @[JSON::Field(key: "canAccessOpener")]
      # Whether the target has access to the originating window.
      getter can_access_opener : Bool
      @[JSON::Field(key: "openerFrameId")]
      # Frame id of originating window (is only set if target has an opener).
      getter opener_frame_id : Page::FrameId?
      @[JSON::Field(key: "browserContextId")]
      getter browser_context_id : Browser::BrowserContextID?
      # Provides additional details for specific target types. For example, for
      # the type of "page", this may be set to "portal" or "prerender".
      getter subtype : String?
    end

    # A filter used by target query/discovery/auto-attach operations.
    struct FilterEntry
      include JSON::Serializable
      # If set, causes exclusion of mathcing targets from the list.
      getter exclude : Bool?
      # If not present, matches any type.
      getter type : String?
    end

    # The entries in TargetFilter are matched sequentially against targets and
    # the first entry that matches determines if the target is included or not,
    # depending on the value of `exclude` field in the entry.
    # If filter is not specified, the one assumed is
    # [{type: "browser", exclude: true}, {type: "tab", exclude: true}, {}]
    # (i.e. include everything but `browser` and `tab`).
    alias TargetFilter = Array(FilterEntry)

    struct RemoteLocation
      include JSON::Serializable
      getter host : String
      getter port : Int::Primitive
    end

    # ----------------------------------------
    # Target Section: commands
    # ----------------------------------------

    # Activates (focuses) the target.
    struct ActivateTarget
      include Protocol::Command
      include JSON::Serializable
    end

    # Attaches to the target with given id.
    struct AttachToTarget
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "sessionId")]
      # Id assigned to the session.
      getter session_id : SessionID
    end

    # Attaches to the browser target, only uses flat sessionId mode.
    struct AttachToBrowserTarget
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "sessionId")]
      # Id assigned to the session.
      getter session_id : SessionID
    end

    # Closes the target. If the target is a page that gets closed too.
    struct CloseTarget
      include Protocol::Command
      include JSON::Serializable
      # Always set to true. If an error occurs, the response indicates protocol error.
      getter success : Bool
    end

    # Inject object to the target's main frame that provides a communication
    # channel with browser target.
    #
    # Injected object will be available as `window[bindingName]`.
    #
    # The object has the follwing API:
    # - `binding.send(json)` - a method to send messages over the remote debugging protocol
    # - `binding.onmessage = json => handleMessage(json)` - a callback that will be called for the protocol notifications and command responses.
    struct ExposeDevToolsProtocol
      include Protocol::Command
      include JSON::Serializable
    end

    # Creates a new empty BrowserContext. Similar to an incognito profile but you can have more than
    # one.
    struct CreateBrowserContext
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "browserContextId")]
      # The id of the context created.
      getter browser_context_id : Browser::BrowserContextID
    end

    # Returns all browser contexts created with `Target.createBrowserContext` method.
    struct GetBrowserContexts
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "browserContextIds")]
      # An array of browser context ids.
      getter browser_context_ids : Array(Browser::BrowserContextID)
    end

    # Creates a new page.
    struct CreateTarget
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "targetId")]
      # The id of the page opened.
      getter target_id : TargetID
    end

    # Detaches session with given id.
    struct DetachFromTarget
      include Protocol::Command
      include JSON::Serializable
    end

    # Deletes a BrowserContext. All the belonging pages will be closed without calling their
    # beforeunload hooks.
    struct DisposeBrowserContext
      include Protocol::Command
      include JSON::Serializable
    end

    # Returns information about a target.
    struct GetTargetInfo
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "targetInfo")]
      getter target_info : TargetInfo
    end

    # Retrieves a list of available targets.
    struct GetTargets
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "targetInfos")]
      # The list of targets.
      getter target_infos : Array(TargetInfo)
    end

    # Sends protocol message over session with given id.
    # Consider using flat mode instead; see commands attachToTarget, setAutoAttach,
    # and crbug.com/991325.
    struct SendMessageToTarget
      include Protocol::Command
      include JSON::Serializable
    end

    # Controls whether to automatically attach to new targets which are considered to be related to
    # this one. When turned on, attaches to all existing related targets as well. When turned off,
    # automatically detaches from all currently attached targets.
    # This also clears all targets added by `autoAttachRelated` from the list of targets to watch
    # for creation of related targets.
    struct SetAutoAttach
      include Protocol::Command
      include JSON::Serializable
    end

    # Adds the specified target to the list of targets that will be monitored for any related target
    # creation (such as child frames, child workers and new versions of service worker) and reported
    # through `attachedToTarget`. The specified target is also auto-attached.
    # This cancels the effect of any previous `setAutoAttach` and is also cancelled by subsequent
    # `setAutoAttach`. Only available at the Browser target.
    struct AutoAttachRelated
      include Protocol::Command
      include JSON::Serializable
    end

    # Controls whether to discover available targets and notify via
    # `targetCreated/targetInfoChanged/targetDestroyed` events.
    struct SetDiscoverTargets
      include Protocol::Command
      include JSON::Serializable
    end

    # Enables target discovery for the specified locations, when `setDiscoverTargets` was set to
    # `true`.
    struct SetRemoteLocations
      include Protocol::Command
      include JSON::Serializable
    end

    # ----------------------------------------
    # Target Section: events
    # ----------------------------------------

    # Issued when attached to target because of auto-attach or `attachToTarget` command.
    struct AttachedToTarget
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "sessionId")]
      # Identifier assigned to the session used to send/receive messages.
      getter session_id : SessionID
      @[JSON::Field(key: "targetInfo")]
      getter target_info : TargetInfo
      @[JSON::Field(key: "waitingForDebugger")]
      getter waiting_for_debugger : Bool
    end

    # Issued when detached from target for any reason (including `detachFromTarget` command). Can be
    # issued multiple times per target if multiple sessions have been attached to it.
    struct DetachedFromTarget
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "sessionId")]
      # Detached session identifier.
      getter session_id : SessionID
      @[JSON::Field(key: "targetId")]
      # Deprecated.
      getter target_id : TargetID?
    end

    # Notifies about a new protocol message received from the session (as reported in
    # `attachedToTarget` event).
    struct ReceivedMessageFromTarget
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "sessionId")]
      # Identifier of a session which sends a message.
      getter session_id : SessionID
      getter message : String
      @[JSON::Field(key: "targetId")]
      # Deprecated.
      getter target_id : TargetID?
    end

    # Issued when a possible inspection target is created.
    struct TargetCreated
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "targetInfo")]
      getter target_info : TargetInfo
    end

    # Issued when a target is destroyed.
    struct TargetDestroyed
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "targetId")]
      getter target_id : TargetID
    end

    # Issued when a target has crashed.
    struct TargetCrashed
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "targetId")]
      getter target_id : TargetID
      # Termination status type.
      getter status : String
      @[JSON::Field(key: "errorCode")]
      # Termination error code.
      getter error_code : Int::Primitive
    end

    # Issued when some information about a target has changed. This only happens between
    # `targetCreated` and `targetDestroyed`.
    struct TargetInfoChanged
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "targetInfo")]
      getter target_info : TargetInfo
    end
  end
end
