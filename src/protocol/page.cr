# ===========================================================================
# Actions and events related to the inspected page belong to the page domain.
# ===========================================================================

# Page module dependencies
require "./debugger"
require "./dom"
require "./io"
require "./network"
require "./runtime"

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module Page
    # ----------------------------------------
    # Page Section: types
    # ----------------------------------------

    # Unique frame identifier.
    alias FrameId = String

    # Indicates whether a frame has been identified as an ad.
    enum AdFrameType
      None  # none
      Child # child
      Root  # root
    end

    enum AdFrameExplanation
      ParentIsAd          # ParentIsAd
      CreatedByAdScript   # CreatedByAdScript
      MatchedBlockingRule # MatchedBlockingRule
    end

    # Indicates whether a frame has been identified as an ad and why.
    struct AdFrameStatus
      include JSON::Serializable
      @[JSON::Field(key: "adFrameType")]
      getter ad_frame_type : AdFrameType
      getter explanations : Array(AdFrameExplanation)?
    end

    # Identifies the bottom-most script which caused the frame to be labelled
    # as an ad.
    struct AdScriptId
      include JSON::Serializable
      @[JSON::Field(key: "scriptId")]
      # Script Id of the bottom-most script which caused the frame to be labelled
      # as an ad.
      getter script_id : Runtime::ScriptId
      @[JSON::Field(key: "debuggerId")]
      # Id of adScriptId's debugger.
      getter debugger_id : Runtime::UniqueDebuggerId
    end

    # Indicates whether the frame is a secure context and why it is the case.
    enum SecureContextType
      Secure           # Secure
      SecureLocalhost  # SecureLocalhost
      InsecureScheme   # InsecureScheme
      InsecureAncestor # InsecureAncestor
    end

    # Indicates whether the frame is cross-origin isolated and why it is the case.
    enum CrossOriginIsolatedContextType
      Isolated                   # Isolated
      NotIsolated                # NotIsolated
      NotIsolatedFeatureDisabled # NotIsolatedFeatureDisabled
    end

    enum GatedAPIFeatures
      SharedArrayBuffers                # SharedArrayBuffers
      SharedArrayBuffersTransferAllowed # SharedArrayBuffersTransferAllowed
      PerformanceMeasureMemory          # PerformanceMeasureMemory
      PerformanceProfile                # PerformanceProfile
    end

    # All Permissions Policy features. This enum should match the one defined
    # in third_party/blink/renderer/core/permissions_policy/permissions_policy_features.json5.
    @[DashEnum]
    enum PermissionsPolicyFeature
      Accelerometer               # accelerometer
      AmbientLightSensor          # ambient-light-sensor
      AttributionReporting        # attribution-reporting
      Autoplay                    # autoplay
      Bluetooth                   # bluetooth
      BrowsingTopics              # browsing-topics
      Camera                      # camera
      ChDpr                       # ch-dpr
      ChDeviceMemory              # ch-device-memory
      ChDownlink                  # ch-downlink
      ChEct                       # ch-ect
      ChPrefersColorScheme        # ch-prefers-color-scheme
      ChPrefersReducedMotion      # ch-prefers-reduced-motion
      ChRtt                       # ch-rtt
      ChSaveData                  # ch-save-data
      ChUa                        # ch-ua
      ChUaArch                    # ch-ua-arch
      ChUaBitness                 # ch-ua-bitness
      ChUaPlatform                # ch-ua-platform
      ChUaModel                   # ch-ua-model
      ChUaMobile                  # ch-ua-mobile
      ChUaFull                    # ch-ua-full
      ChUaFullVersion             # ch-ua-full-version
      ChUaFullVersionList         # ch-ua-full-version-list
      ChUaPlatformVersion         # ch-ua-platform-version
      ChUaReduced                 # ch-ua-reduced
      ChUaWow64                   # ch-ua-wow64
      ChViewportHeight            # ch-viewport-height
      ChViewportWidth             # ch-viewport-width
      ChWidth                     # ch-width
      ClipboardRead               # clipboard-read
      ClipboardWrite              # clipboard-write
      CrossOriginIsolated         # cross-origin-isolated
      DirectSockets               # direct-sockets
      DisplayCapture              # display-capture
      DocumentDomain              # document-domain
      EncryptedMedia              # encrypted-media
      ExecutionWhileOutOfViewport # execution-while-out-of-viewport
      ExecutionWhileNotRendered   # execution-while-not-rendered
      FocusWithoutUserActivation  # focus-without-user-activation
      Fullscreen                  # fullscreen
      Frobulate                   # frobulate
      Gamepad                     # gamepad
      Geolocation                 # geolocation
      Gyroscope                   # gyroscope
      Hid                         # hid
      IdentityCredentialsGet      # identity-credentials-get
      IdleDetection               # idle-detection
      InterestCohort              # interest-cohort
      JoinAdInterestGroup         # join-ad-interest-group
      KeyboardMap                 # keyboard-map
      LocalFonts                  # local-fonts
      Magnetometer                # magnetometer
      Microphone                  # microphone
      Midi                        # midi
      OtpCredentials              # otp-credentials
      Payment                     # payment
      PictureInPicture            # picture-in-picture
      PublickeyCredentialsGet     # publickey-credentials-get
      RunAdAuction                # run-ad-auction
      ScreenWakeLock              # screen-wake-lock
      Serial                      # serial
      SharedAutofill              # shared-autofill
      SharedStorage               # shared-storage
      StorageAccess               # storage-access
      SyncXhr                     # sync-xhr
      TrustTokenRedemption        # trust-token-redemption
      Unload                      # unload
      Usb                         # usb
      VerticalScroll              # vertical-scroll
      WebShare                    # web-share
      WindowPlacement             # window-placement
      XrSpatialTracking           # xr-spatial-tracking
    end

    # Reason for a permissions policy feature to be disabled.
    enum PermissionsPolicyBlockReason
      Header            # Header
      IframeAttribute   # IframeAttribute
      InFencedFrameTree # InFencedFrameTree
      InIsolatedApp     # InIsolatedApp
    end

    struct PermissionsPolicyBlockLocator
      include JSON::Serializable
      @[JSON::Field(key: "frameId")]
      getter frame_id : FrameId
      @[JSON::Field(key: "blockReason")]
      getter block_reason : PermissionsPolicyBlockReason
    end

    struct PermissionsPolicyFeatureState
      include JSON::Serializable
      getter feature : PermissionsPolicyFeature
      getter allowed : Bool
      getter locator : PermissionsPolicyBlockLocator?
    end

    # Origin Trial(https://www.chromium.org/blink/origin-trials) support.
    # Status for an Origin Trial token.
    enum OriginTrialTokenStatus
      Success                # Success
      NotSupported           # NotSupported
      Insecure               # Insecure
      Expired                # Expired
      WrongOrigin            # WrongOrigin
      InvalidSignature       # InvalidSignature
      Malformed              # Malformed
      WrongVersion           # WrongVersion
      FeatureDisabled        # FeatureDisabled
      TokenDisabled          # TokenDisabled
      FeatureDisabledForUser # FeatureDisabledForUser
      UnknownTrial           # UnknownTrial
    end

    # Status for an Origin Trial.
    enum OriginTrialStatus
      Enabled               # Enabled
      ValidTokenNotProvided # ValidTokenNotProvided
      OSNotSupported        # OSNotSupported
      TrialNotAllowed       # TrialNotAllowed
    end

    enum OriginTrialUsageRestriction
      None   # None
      Subset # Subset
    end

    struct OriginTrialToken
      include JSON::Serializable
      getter origin : String
      @[JSON::Field(key: "matchSubDomains")]
      getter match_sub_domains : Bool
      @[JSON::Field(key: "trialName")]
      getter trial_name : String
      @[JSON::Field(key: "expiryTime")]
      getter expiry_time : Network::TimeSinceEpoch
      @[JSON::Field(key: "isThirdParty")]
      getter is_third_party : Bool
      @[JSON::Field(key: "usageRestriction")]
      getter usage_restriction : OriginTrialUsageRestriction
    end

    struct OriginTrialTokenWithStatus
      include JSON::Serializable
      @[JSON::Field(key: "rawTokenText")]
      getter raw_token_text : String
      @[JSON::Field(key: "parsedToken")]
      # `parsedToken` is present only when the token is extractable and
      # parsable.
      getter parsed_token : OriginTrialToken?
      getter status : OriginTrialTokenStatus
    end

    struct OriginTrial
      include JSON::Serializable
      @[JSON::Field(key: "trialName")]
      getter trial_name : String
      getter status : OriginTrialStatus
      @[JSON::Field(key: "tokensWithStatus")]
      getter tokens_with_status : Array(OriginTrialTokenWithStatus)
    end

    # Information about the Frame on the page.
    struct Frame
      include JSON::Serializable
      # Frame unique identifier.
      getter id : FrameId
      @[JSON::Field(key: "parentId")]
      # Parent frame identifier.
      getter parent_id : FrameId?
      @[JSON::Field(key: "loaderId")]
      # Identifier of the loader associated with this frame.
      getter loader_id : Network::LoaderId
      # Frame's name as specified in the tag.
      getter name : String?
      # Frame document's URL without fragment.
      getter url : String
      @[JSON::Field(key: "urlFragment")]
      # Frame document's URL fragment including the '#'.
      getter url_fragment : String?
      @[JSON::Field(key: "domainAndRegistry")]
      # Frame document's registered domain, taking the public suffixes list into account.
      # Extracted from the Frame's url.
      # Example URLs: http://www.google.com/file.html -> "google.com"
      #               http://a.b.co.uk/file.html      -> "b.co.uk"
      getter domain_and_registry : String
      @[JSON::Field(key: "securityOrigin")]
      # Frame document's security origin.
      getter security_origin : String
      @[JSON::Field(key: "mimeType")]
      # Frame document's mimeType as determined by the browser.
      getter mime_type : String
      @[JSON::Field(key: "unreachableUrl")]
      # If the frame failed to load, this contains the URL that could not be loaded. Note that unlike url above, this URL may contain a fragment.
      getter unreachable_url : String?
      @[JSON::Field(key: "adFrameStatus")]
      # Indicates whether this frame was tagged as an ad and why.
      getter ad_frame_status : AdFrameStatus?
      @[JSON::Field(key: "secureContextType")]
      # Indicates whether the main document is a secure context and explains why that is the case.
      getter secure_context_type : SecureContextType
      @[JSON::Field(key: "crossOriginIsolatedContextType")]
      # Indicates whether this is a cross origin isolated context.
      getter cross_origin_isolated_context_type : CrossOriginIsolatedContextType
      @[JSON::Field(key: "gatedAPIFeatures")]
      # Indicated which gated APIs / features are available.
      getter gated_api_features : Array(GatedAPIFeatures)
    end

    # Information about the Resource on the page.
    struct FrameResource
      include JSON::Serializable
      # Resource URL.
      getter url : String
      # Type of this resource.
      getter type : Network::ResourceType
      @[JSON::Field(key: "mimeType")]
      # Resource mimeType as determined by the browser.
      getter mime_type : String
      @[JSON::Field(key: "lastModified")]
      # last-modified timestamp as reported by server.
      getter last_modified : Network::TimeSinceEpoch?
      @[JSON::Field(key: "contentSize")]
      # Resource content size.
      getter content_size : Number::Primitive?
      # True if the resource failed to load.
      getter failed : Bool?
      # True if the resource was canceled during loading.
      getter canceled : Bool?
    end

    # Information about the Frame hierarchy along with their cached resources.
    struct FrameResourceTree
      include JSON::Serializable
      # Frame information for this tree item.
      getter frame : Frame
      @[JSON::Field(key: "childFrames")]
      # Child frames.
      getter child_frames : Array(FrameResourceTree)?
      # Information about frame resources.
      getter resources : Array(FrameResource)
    end

    # Information about the Frame hierarchy.
    struct FrameTree
      include JSON::Serializable
      # Frame information for this tree item.
      getter frame : Frame
      @[JSON::Field(key: "childFrames")]
      # Child frames.
      getter child_frames : Array(FrameTree)?
    end

    # Unique script identifier.
    alias ScriptIdentifier = String

    # Transition type.
    enum TransitionType
      Link             # link
      Typed            # typed
      AddressBar       # address_bar
      AutoBookmark     # auto_bookmark
      AutoSubframe     # auto_subframe
      ManualSubframe   # manual_subframe
      Generated        # generated
      AutoToplevel     # auto_toplevel
      FormSubmit       # form_submit
      Reload           # reload
      Keyword          # keyword
      KeywordGenerated # keyword_generated
      Other            # other
    end

    # Navigation history entry.
    struct NavigationEntry
      include JSON::Serializable
      # Unique id of the navigation history entry.
      getter id : Int::Primitive
      # URL of the navigation history entry.
      getter url : String
      @[JSON::Field(key: "userTypedURL")]
      # URL that the user typed in the url bar.
      getter user_typed_url : String
      # Title of the navigation history entry.
      getter title : String
      @[JSON::Field(key: "transitionType")]
      # Transition type.
      getter transition_type : TransitionType
    end

    # Screencast frame metadata.
    struct ScreencastFrameMetadata
      include JSON::Serializable
      @[JSON::Field(key: "offsetTop")]
      # Top offset in DIP.
      getter offset_top : Number::Primitive
      @[JSON::Field(key: "pageScaleFactor")]
      # Page scale factor.
      getter page_scale_factor : Number::Primitive
      @[JSON::Field(key: "deviceWidth")]
      # Device screen width in DIP.
      getter device_width : Number::Primitive
      @[JSON::Field(key: "deviceHeight")]
      # Device screen height in DIP.
      getter device_height : Number::Primitive
      @[JSON::Field(key: "scrollOffsetX")]
      # Position of horizontal scroll in CSS pixels.
      getter scroll_offset_x : Number::Primitive
      @[JSON::Field(key: "scrollOffsetY")]
      # Position of vertical scroll in CSS pixels.
      getter scroll_offset_y : Number::Primitive
      # Frame swap timestamp.
      getter timestamp : Network::TimeSinceEpoch?
    end

    # Javascript dialog type.
    enum DialogType
      Alert        # alert
      Confirm      # confirm
      Prompt       # prompt
      Beforeunload # beforeunload
    end

    # Error while paring app manifest.
    struct AppManifestError
      include JSON::Serializable
      # Error message.
      getter message : String
      # If criticial, this is a non-recoverable parse error.
      getter critical : Int::Primitive
      # Error line.
      getter line : Int::Primitive
      # Error column.
      getter column : Int::Primitive
    end

    # Parsed app manifest properties.
    struct AppManifestParsedProperties
      include JSON::Serializable
      # Computed scope value
      getter scope : String
    end

    # Layout viewport position and dimensions.
    struct LayoutViewport
      include JSON::Serializable
      @[JSON::Field(key: "pageX")]
      # Horizontal offset relative to the document (CSS pixels).
      getter page_x : Int::Primitive
      @[JSON::Field(key: "pageY")]
      # Vertical offset relative to the document (CSS pixels).
      getter page_y : Int::Primitive
      @[JSON::Field(key: "clientWidth")]
      # Width (CSS pixels), excludes scrollbar if present.
      getter client_width : Int::Primitive
      @[JSON::Field(key: "clientHeight")]
      # Height (CSS pixels), excludes scrollbar if present.
      getter client_height : Int::Primitive
    end

    # Visual viewport position, dimensions, and scale.
    struct VisualViewport
      include JSON::Serializable
      @[JSON::Field(key: "offsetX")]
      # Horizontal offset relative to the layout viewport (CSS pixels).
      getter offset_x : Number::Primitive
      @[JSON::Field(key: "offsetY")]
      # Vertical offset relative to the layout viewport (CSS pixels).
      getter offset_y : Number::Primitive
      @[JSON::Field(key: "pageX")]
      # Horizontal offset relative to the document (CSS pixels).
      getter page_x : Number::Primitive
      @[JSON::Field(key: "pageY")]
      # Vertical offset relative to the document (CSS pixels).
      getter page_y : Number::Primitive
      @[JSON::Field(key: "clientWidth")]
      # Width (CSS pixels), excludes scrollbar if present.
      getter client_width : Number::Primitive
      @[JSON::Field(key: "clientHeight")]
      # Height (CSS pixels), excludes scrollbar if present.
      getter client_height : Number::Primitive
      # Scale relative to the ideal viewport (size at width=device-width).
      getter scale : Number::Primitive
      # Page zoom factor (CSS to device independent pixels ratio).
      getter zoom : Number::Primitive?
    end

    # Viewport for capturing screenshot.
    struct Viewport
      include JSON::Serializable
      # X offset in device independent pixels (dip).
      getter x : Number::Primitive
      # Y offset in device independent pixels (dip).
      getter y : Number::Primitive
      # Rectangle width in device independent pixels (dip).
      getter width : Number::Primitive
      # Rectangle height in device independent pixels (dip).
      getter height : Number::Primitive
      # Page scale factor.
      getter scale : Number::Primitive
    end

    # Generic font families collection.
    struct FontFamilies
      include JSON::Serializable
      # The standard font-family.
      getter standard : String?
      # The fixed font-family.
      getter fixed : String?
      # The serif font-family.
      getter serif : String?
      @[JSON::Field(key: "sansSerif")]
      # The sansSerif font-family.
      getter sans_serif : String?
      # The cursive font-family.
      getter cursive : String?
      # The fantasy font-family.
      getter fantasy : String?
      # The math font-family.
      getter math : String?
    end

    # Font families collection for a script.
    struct ScriptFontFamilies
      include JSON::Serializable
      # Name of the script which these font families are defined for.
      getter script : String
      @[JSON::Field(key: "fontFamilies")]
      # Generic font families collection for the script.
      getter font_families : FontFamilies
    end

    # Default font sizes.
    struct FontSizes
      include JSON::Serializable
      # Default standard font size.
      getter standard : Int::Primitive?
      # Default fixed font size.
      getter fixed : Int::Primitive?
    end

    enum ClientNavigationReason
      FormSubmissionGet     # formSubmissionGet
      FormSubmissionPost    # formSubmissionPost
      HttpHeaderRefresh     # httpHeaderRefresh
      ScriptInitiated       # scriptInitiated
      MetaTagRefresh        # metaTagRefresh
      PageBlockInterstitial # pageBlockInterstitial
      Reload                # reload
      AnchorClick           # anchorClick
    end

    enum ClientNavigationDisposition
      CurrentTab # currentTab
      NewTab     # newTab
      NewWindow  # newWindow
      Download   # download
    end

    struct InstallabilityErrorArgument
      include JSON::Serializable
      # Argument name (e.g. name:'minimum-icon-size-in-pixels').
      getter name : String
      # Argument value (e.g. value:'64').
      getter value : String
    end

    # The installability error
    struct InstallabilityError
      include JSON::Serializable
      @[JSON::Field(key: "errorId")]
      # The error id (e.g. 'manifest-missing-suitable-icon').
      getter error_id : String
      @[JSON::Field(key: "errorArguments")]
      # The list of error arguments (e.g. {name:'minimum-icon-size-in-pixels', value:'64'}).
      getter error_arguments : Array(InstallabilityErrorArgument)
    end

    # The referring-policy used for the navigation.
    enum ReferrerPolicy
      NoReferrer                  # noReferrer
      NoReferrerWhenDowngrade     # noReferrerWhenDowngrade
      Origin                      # origin
      OriginWhenCrossOrigin       # originWhenCrossOrigin
      SameOrigin                  # sameOrigin
      StrictOrigin                # strictOrigin
      StrictOriginWhenCrossOrigin # strictOriginWhenCrossOrigin
      UnsafeUrl                   # unsafeUrl
    end

    # Per-script compilation cache parameters for `Page.produceCompilationCache`
    struct CompilationCacheParams
      include JSON::Serializable
      # The URL of the script to produce a compilation cache entry for.
      getter url : String
      # A hint to the backend whether eager compilation is recommended.
      # (the actual compilation mode used is upon backend discretion).
      getter eager : Bool?
    end

    # The type of a frameNavigated event.
    enum NavigationType
      Navigation              # Navigation
      BackForwardCacheRestore # BackForwardCacheRestore
    end

    # List of not restored reasons for back-forward cache.
    enum BackForwardCacheNotRestoredReason
      NotPrimaryMainFrame                                      # NotPrimaryMainFrame
      BackForwardCacheDisabled                                 # BackForwardCacheDisabled
      RelatedActiveContentsExist                               # RelatedActiveContentsExist
      HTTPStatusNotOK                                          # HTTPStatusNotOK
      SchemeNotHTTPOrHTTPS                                     # SchemeNotHTTPOrHTTPS
      Loading                                                  # Loading
      WasGrantedMediaAccess                                    # WasGrantedMediaAccess
      DisableForRenderFrameHostCalled                          # DisableForRenderFrameHostCalled
      DomainNotAllowed                                         # DomainNotAllowed
      HTTPMethodNotGET                                         # HTTPMethodNotGET
      SubframeIsNavigating                                     # SubframeIsNavigating
      Timeout                                                  # Timeout
      CacheLimit                                               # CacheLimit
      JavaScriptExecution                                      # JavaScriptExecution
      RendererProcessKilled                                    # RendererProcessKilled
      RendererProcessCrashed                                   # RendererProcessCrashed
      SchedulerTrackedFeatureUsed                              # SchedulerTrackedFeatureUsed
      ConflictingBrowsingInstance                              # ConflictingBrowsingInstance
      CacheFlushed                                             # CacheFlushed
      ServiceWorkerVersionActivation                           # ServiceWorkerVersionActivation
      SessionRestored                                          # SessionRestored
      ServiceWorkerPostMessage                                 # ServiceWorkerPostMessage
      EnteredBackForwardCacheBeforeServiceWorkerHostAdded      # EnteredBackForwardCacheBeforeServiceWorkerHostAdded
      RenderFrameHostReusedSameSite                            # RenderFrameHostReused_SameSite
      RenderFrameHostReusedCrossSite                           # RenderFrameHostReused_CrossSite
      ServiceWorkerClaim                                       # ServiceWorkerClaim
      IgnoreEventAndEvict                                      # IgnoreEventAndEvict
      HaveInnerContents                                        # HaveInnerContents
      TimeoutPuttingInCache                                    # TimeoutPuttingInCache
      BackForwardCacheDisabledByLowMemory                      # BackForwardCacheDisabledByLowMemory
      BackForwardCacheDisabledByCommandLine                    # BackForwardCacheDisabledByCommandLine
      NetworkRequestDatapipeDrainedAsBytesConsumer             # NetworkRequestDatapipeDrainedAsBytesConsumer
      NetworkRequestRedirected                                 # NetworkRequestRedirected
      NetworkRequestTimeout                                    # NetworkRequestTimeout
      NetworkExceedsBufferLimit                                # NetworkExceedsBufferLimit
      NavigationCancelledWhileRestoring                        # NavigationCancelledWhileRestoring
      NotMostRecentNavigationEntry                             # NotMostRecentNavigationEntry
      BackForwardCacheDisabledForPrerender                     # BackForwardCacheDisabledForPrerender
      UserAgentOverrideDiffers                                 # UserAgentOverrideDiffers
      ForegroundCacheLimit                                     # ForegroundCacheLimit
      BrowsingInstanceNotSwapped                               # BrowsingInstanceNotSwapped
      BackForwardCacheDisabledForDelegate                      # BackForwardCacheDisabledForDelegate
      UnloadHandlerExistsInMainFrame                           # UnloadHandlerExistsInMainFrame
      UnloadHandlerExistsInSubFrame                            # UnloadHandlerExistsInSubFrame
      ServiceWorkerUnregistration                              # ServiceWorkerUnregistration
      CacheControlNoStore                                      # CacheControlNoStore
      CacheControlNoStoreCookieModified                        # CacheControlNoStoreCookieModified
      CacheControlNoStoreHTTPOnlyCookieModified                # CacheControlNoStoreHTTPOnlyCookieModified
      NoResponseHead                                           # NoResponseHead
      Unknown                                                  # Unknown
      ActivationNavigationsDisallowedForBug1234857             # ActivationNavigationsDisallowedForBug1234857
      ErrorDocument                                            # ErrorDocument
      FencedFramesEmbedder                                     # FencedFramesEmbedder
      WebSocket                                                # WebSocket
      WebTransport                                             # WebTransport
      WebRTC                                                   # WebRTC
      MainResourceHasCacheControlNoStore                       # MainResourceHasCacheControlNoStore
      MainResourceHasCacheControlNoCache                       # MainResourceHasCacheControlNoCache
      SubresourceHasCacheControlNoStore                        # SubresourceHasCacheControlNoStore
      SubresourceHasCacheControlNoCache                        # SubresourceHasCacheControlNoCache
      ContainsPlugins                                          # ContainsPlugins
      DocumentLoaded                                           # DocumentLoaded
      DedicatedWorkerOrWorklet                                 # DedicatedWorkerOrWorklet
      OutstandingNetworkRequestOthers                          # OutstandingNetworkRequestOthers
      OutstandingIndexedDBTransaction                          # OutstandingIndexedDBTransaction
      RequestedNotificationsPermission                         # RequestedNotificationsPermission
      RequestedMIDIPermission                                  # RequestedMIDIPermission
      RequestedAudioCapturePermission                          # RequestedAudioCapturePermission
      RequestedVideoCapturePermission                          # RequestedVideoCapturePermission
      RequestedBackForwardCacheBlockedSensors                  # RequestedBackForwardCacheBlockedSensors
      RequestedBackgroundWorkPermission                        # RequestedBackgroundWorkPermission
      BroadcastChannel                                         # BroadcastChannel
      IndexedDBConnection                                      # IndexedDBConnection
      WebXR                                                    # WebXR
      SharedWorker                                             # SharedWorker
      WebLocks                                                 # WebLocks
      WebHID                                                   # WebHID
      WebShare                                                 # WebShare
      RequestedStorageAccessGrant                              # RequestedStorageAccessGrant
      WebNfc                                                   # WebNfc
      OutstandingNetworkRequestFetch                           # OutstandingNetworkRequestFetch
      OutstandingNetworkRequestXHR                             # OutstandingNetworkRequestXHR
      AppBanner                                                # AppBanner
      Printing                                                 # Printing
      WebDatabase                                              # WebDatabase
      PictureInPicture                                         # PictureInPicture
      Portal                                                   # Portal
      SpeechRecognizer                                         # SpeechRecognizer
      IdleManager                                              # IdleManager
      PaymentManager                                           # PaymentManager
      SpeechSynthesis                                          # SpeechSynthesis
      KeyboardLock                                             # KeyboardLock
      WebOTPService                                            # WebOTPService
      OutstandingNetworkRequestDirectSocket                    # OutstandingNetworkRequestDirectSocket
      InjectedJavascript                                       # InjectedJavascript
      InjectedStyleSheet                                       # InjectedStyleSheet
      KeepaliveRequest                                         # KeepaliveRequest
      Dummy                                                    # Dummy
      ContentSecurityHandler                                   # ContentSecurityHandler
      ContentWebAuthenticationAPI                              # ContentWebAuthenticationAPI
      ContentFileChooser                                       # ContentFileChooser
      ContentSerial                                            # ContentSerial
      ContentFileSystemAccess                                  # ContentFileSystemAccess
      ContentMediaDevicesDispatcherHost                        # ContentMediaDevicesDispatcherHost
      ContentWebBluetooth                                      # ContentWebBluetooth
      ContentWebUSB                                            # ContentWebUSB
      ContentMediaSessionService                               # ContentMediaSessionService
      ContentScreenReader                                      # ContentScreenReader
      EmbedderPopupBlockerTabHelper                            # EmbedderPopupBlockerTabHelper
      EmbedderSafeBrowsingTriggeredPopupBlocker                # EmbedderSafeBrowsingTriggeredPopupBlocker
      EmbedderSafeBrowsingThreatDetails                        # EmbedderSafeBrowsingThreatDetails
      EmbedderAppBannerManager                                 # EmbedderAppBannerManager
      EmbedderDomDistillerViewerSource                         # EmbedderDomDistillerViewerSource
      EmbedderDomDistillerSelfDeletingRequestDelegate          # EmbedderDomDistillerSelfDeletingRequestDelegate
      EmbedderOomInterventionTabHelper                         # EmbedderOomInterventionTabHelper
      EmbedderOfflinePage                                      # EmbedderOfflinePage
      EmbedderChromePasswordManagerClientBindCredentialManager # EmbedderChromePasswordManagerClientBindCredentialManager
      EmbedderPermissionRequestManager                         # EmbedderPermissionRequestManager
      EmbedderModalDialog                                      # EmbedderModalDialog
      EmbedderExtensions                                       # EmbedderExtensions
      EmbedderExtensionMessaging                               # EmbedderExtensionMessaging
      EmbedderExtensionMessagingForOpenPort                    # EmbedderExtensionMessagingForOpenPort
      EmbedderExtensionSentMessageToCachedFrame                # EmbedderExtensionSentMessageToCachedFrame
    end

    # Types of not restored reasons for back-forward cache.
    enum BackForwardCacheNotRestoredReasonType
      SupportPending    # SupportPending
      PageSupportNeeded # PageSupportNeeded
      Circumstantial    # Circumstantial
    end

    struct BackForwardCacheNotRestoredExplanation
      include JSON::Serializable
      # Type of the reason
      getter type : BackForwardCacheNotRestoredReasonType
      # Not restored reason
      getter reason : BackForwardCacheNotRestoredReason
      # Context associated with the reason. The meaning of this context is
      # dependent on the reason:
      # - EmbedderExtensionSentMessageToCachedFrame: the extension ID.
      getter context : String?
    end

    struct BackForwardCacheNotRestoredExplanationTree
      include JSON::Serializable
      # URL of each frame
      getter url : String
      # Not restored reasons of each frame
      getter explanations : Array(BackForwardCacheNotRestoredExplanation)
      # Array of children frame
      getter children : Array(BackForwardCacheNotRestoredExplanationTree)
    end

    # List of FinalStatus reasons for Prerender2.
    enum PrerenderFinalStatus
      Activated                                 # Activated
      Destroyed                                 # Destroyed
      LowEndDevice                              # LowEndDevice
      InvalidSchemeRedirect                     # InvalidSchemeRedirect
      InvalidSchemeNavigation                   # InvalidSchemeNavigation
      InProgressNavigation                      # InProgressNavigation
      NavigationRequestBlockedByCsp             # NavigationRequestBlockedByCsp
      MainFrameNavigation                       # MainFrameNavigation
      MojoBinderPolicy                          # MojoBinderPolicy
      RendererProcessCrashed                    # RendererProcessCrashed
      RendererProcessKilled                     # RendererProcessKilled
      Download                                  # Download
      TriggerDestroyed                          # TriggerDestroyed
      NavigationNotCommitted                    # NavigationNotCommitted
      NavigationBadHttpStatus                   # NavigationBadHttpStatus
      ClientCertRequested                       # ClientCertRequested
      NavigationRequestNetworkError             # NavigationRequestNetworkError
      MaxNumOfRunningPrerendersExceeded         # MaxNumOfRunningPrerendersExceeded
      CancelAllHostsForTesting                  # CancelAllHostsForTesting
      DidFailLoad                               # DidFailLoad
      Stop                                      # Stop
      SslCertificateError                       # SslCertificateError
      LoginAuthRequested                        # LoginAuthRequested
      UaChangeRequiresReload                    # UaChangeRequiresReload
      BlockedByClient                           # BlockedByClient
      AudioOutputDeviceRequested                # AudioOutputDeviceRequested
      MixedContent                              # MixedContent
      TriggerBackgrounded                       # TriggerBackgrounded
      EmbedderTriggeredAndCrossOriginRedirected # EmbedderTriggeredAndCrossOriginRedirected
      MemoryLimitExceeded                       # MemoryLimitExceeded
      FailToGetMemoryUsage                      # FailToGetMemoryUsage
      DataSaverEnabled                          # DataSaverEnabled
      HasEffectiveUrl                           # HasEffectiveUrl
      ActivatedBeforeStarted                    # ActivatedBeforeStarted
      InactivePageRestriction                   # InactivePageRestriction
      StartFailed                               # StartFailed
      TimeoutBackgrounded                       # TimeoutBackgrounded
      CrossSiteRedirect                         # CrossSiteRedirect
      CrossSiteNavigation                       # CrossSiteNavigation
      SameSiteCrossOriginRedirect               # SameSiteCrossOriginRedirect
      SameSiteCrossOriginNavigation             # SameSiteCrossOriginNavigation
      SameSiteCrossOriginRedirectNotOptIn       # SameSiteCrossOriginRedirectNotOptIn
      SameSiteCrossOriginNavigationNotOptIn     # SameSiteCrossOriginNavigationNotOptIn
    end

    # ----------------------------------------
    # Page Section: commands
    # ----------------------------------------

    # Deprecated, please use addScriptToEvaluateOnNewDocument instead.
    struct AddScriptToEvaluateOnLoad
      include Protocol::Command
      include JSON::Serializable
      # Identifier of the added script.
      getter identifier : ScriptIdentifier
    end

    # Evaluates given script in every frame upon creation (before loading frame's scripts).
    struct AddScriptToEvaluateOnNewDocument
      include Protocol::Command
      include JSON::Serializable
      # Identifier of the added script.
      getter identifier : ScriptIdentifier
    end

    # Brings page to front (activates tab).
    struct BringToFront
      include Protocol::Command
      include JSON::Serializable
    end

    # Capture page screenshot.
    struct CaptureScreenshot
      include Protocol::Command
      include JSON::Serializable
      # Base64-encoded image data. (Encoded as a base64 string when passed over JSON)
      getter data : String
    end

    # Returns a snapshot of the page as a string. For MHTML format, the serialization includes
    # iframes, shadow DOM, external resources, and element-inline styles.
    struct CaptureSnapshot
      include Protocol::Command
      include JSON::Serializable
      # Serialized page data.
      getter data : String
    end

    # Clears the overridden device metrics.
    struct ClearDeviceMetricsOverride
      include Protocol::Command
      include JSON::Serializable
    end

    # Clears the overridden Device Orientation.
    struct ClearDeviceOrientationOverride
      include Protocol::Command
      include JSON::Serializable
    end

    # Clears the overridden Geolocation Position and Error.
    struct ClearGeolocationOverride
      include Protocol::Command
      include JSON::Serializable
    end

    # Creates an isolated world for the given frame.
    struct CreateIsolatedWorld
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "executionContextId")]
      # Execution context of the isolated world.
      getter execution_context_id : Runtime::ExecutionContextId
    end

    # Deletes browser cookie with given name, domain and path.
    struct DeleteCookie
      include Protocol::Command
      include JSON::Serializable
    end

    # Disables page domain notifications.
    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    # Enables page domain notifications.
    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    struct GetAppManifest
      include Protocol::Command
      include JSON::Serializable
      # Manifest location.
      getter url : String
      getter errors : Array(AppManifestError)
      # Manifest content.
      getter data : String?
      # Parsed manifest properties
      getter parsed : AppManifestParsedProperties?
    end

    struct GetInstallabilityErrors
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "installabilityErrors")]
      getter installability_errors : Array(InstallabilityError)
    end

    struct GetManifestIcons
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "primaryIcon")]
      getter primary_icon : String?
    end

    # Returns the unique (PWA) app id.
    # Only returns values if the feature flag 'WebAppEnableManifestId' is enabled
    struct GetAppId
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "appId")]
      # App id, either from manifest's id attribute or computed from start_url
      getter app_id : String?
      @[JSON::Field(key: "recommendedId")]
      # Recommendation for manifest's id attribute to match current id computed from start_url
      getter recommended_id : String?
    end

    struct GetAdScriptId
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "adScriptId")]
      # Identifies the bottom-most script which caused the frame to be labelled
      # as an ad. Only sent if frame is labelled as an ad and id is available.
      getter ad_script_id : AdScriptId?
    end

    # Returns all browser cookies for the page and all of its subframes. Depending
    # on the backend support, will return detailed cookie information in the
    # `cookies` field.
    struct GetCookies
      include Protocol::Command
      include JSON::Serializable
      # Array of cookie objects.
      getter cookies : Array(Network::Cookie)
    end

    # Returns present frame tree structure.
    struct GetFrameTree
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "frameTree")]
      # Present frame tree structure.
      getter frame_tree : FrameTree
    end

    # Returns metrics relating to the layouting of the page, such as viewport bounds/scale.
    struct GetLayoutMetrics
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "layoutViewport")]
      # Deprecated metrics relating to the layout viewport. Is in device pixels. Use `cssLayoutViewport` instead.
      getter layout_viewport : LayoutViewport
      @[JSON::Field(key: "visualViewport")]
      # Deprecated metrics relating to the visual viewport. Is in device pixels. Use `cssVisualViewport` instead.
      getter visual_viewport : VisualViewport
      @[JSON::Field(key: "contentSize")]
      # Deprecated size of scrollable area. Is in DP. Use `cssContentSize` instead.
      getter content_size : DOM::Rect
      @[JSON::Field(key: "cssLayoutViewport")]
      # Metrics relating to the layout viewport in CSS pixels.
      getter css_layout_viewport : LayoutViewport
      @[JSON::Field(key: "cssVisualViewport")]
      # Metrics relating to the visual viewport in CSS pixels.
      getter css_visual_viewport : VisualViewport
      @[JSON::Field(key: "cssContentSize")]
      # Size of scrollable area in CSS pixels.
      getter css_content_size : DOM::Rect
    end

    # Returns navigation history for the current page.
    struct GetNavigationHistory
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "currentIndex")]
      # Index of the current navigation history entry.
      getter current_index : Int::Primitive
      # Array of navigation history entries.
      getter entries : Array(NavigationEntry)
    end

    # Resets navigation history for the current page.
    struct ResetNavigationHistory
      include Protocol::Command
      include JSON::Serializable
    end

    # Returns content of the given resource.
    struct GetResourceContent
      include Protocol::Command
      include JSON::Serializable
      # Resource content.
      getter content : String
      @[JSON::Field(key: "base64Encoded")]
      # True, if content was served as base64.
      getter base64_encoded : Bool
    end

    # Returns present frame / resource tree structure.
    struct GetResourceTree
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "frameTree")]
      # Present frame / resource tree structure.
      getter frame_tree : FrameResourceTree
    end

    # Accepts or dismisses a JavaScript initiated dialog (alert, confirm, prompt, or onbeforeunload).
    struct HandleJavaScriptDialog
      include Protocol::Command
      include JSON::Serializable
    end

    # Navigates current page to the given URL.
    struct Navigate
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "frameId")]
      # Frame id that has navigated (or failed to navigate)
      getter frame_id : FrameId
      @[JSON::Field(key: "loaderId")]
      # Loader identifier. This is omitted in case of same-document navigation,
      # as the previously committed loaderId would not change.
      getter loader_id : Network::LoaderId?
      @[JSON::Field(key: "errorText")]
      # User friendly error message, present if and only if navigation has failed.
      getter error_text : String?
    end

    # Navigates current page to the given history entry.
    struct NavigateToHistoryEntry
      include Protocol::Command
      include JSON::Serializable
    end

    # Print page as PDF.
    struct PrintToPDF
      include Protocol::Command
      include JSON::Serializable
      # Base64-encoded pdf data. Empty if |returnAsStream| is specified. (Encoded as a base64 string when passed over JSON)
      getter data : String
      # A handle of the stream that holds resulting PDF data.
      getter stream : IO::StreamHandle?
    end

    # Reloads given page optionally ignoring the cache.
    struct Reload
      include Protocol::Command
      include JSON::Serializable
    end

    # Deprecated, please use removeScriptToEvaluateOnNewDocument instead.
    struct RemoveScriptToEvaluateOnLoad
      include Protocol::Command
      include JSON::Serializable
    end

    # Removes given script from the list.
    struct RemoveScriptToEvaluateOnNewDocument
      include Protocol::Command
      include JSON::Serializable
    end

    # Acknowledges that a screencast frame has been received by the frontend.
    struct ScreencastFrameAck
      include Protocol::Command
      include JSON::Serializable
    end

    # Searches for given string in resource content.
    struct SearchInResource
      include Protocol::Command
      include JSON::Serializable
      # List of search matches.
      getter result : Array(Debugger::SearchMatch)
    end

    # Enable Chrome's experimental ad filter on all sites.
    struct SetAdBlockingEnabled
      include Protocol::Command
      include JSON::Serializable
    end

    # Enable page Content Security Policy by-passing.
    struct SetBypassCSP
      include Protocol::Command
      include JSON::Serializable
    end

    # Get Permissions Policy state on given frame.
    struct GetPermissionsPolicyState
      include Protocol::Command
      include JSON::Serializable
      getter states : Array(PermissionsPolicyFeatureState)
    end

    # Get Origin Trials on given frame.
    struct GetOriginTrials
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "originTrials")]
      getter origin_trials : Array(OriginTrial)
    end

    # Overrides the values of device screen dimensions (window.screen.width, window.screen.height,
    # window.innerWidth, window.innerHeight, and "device-width"/"device-height"-related CSS media
    # query results).
    struct SetDeviceMetricsOverride
      include Protocol::Command
      include JSON::Serializable
    end

    # Overrides the Device Orientation.
    struct SetDeviceOrientationOverride
      include Protocol::Command
      include JSON::Serializable
    end

    # Set generic font families.
    struct SetFontFamilies
      include Protocol::Command
      include JSON::Serializable
    end

    # Set default font sizes.
    struct SetFontSizes
      include Protocol::Command
      include JSON::Serializable
    end

    # Sets given markup as the document's HTML.
    struct SetDocumentContent
      include Protocol::Command
      include JSON::Serializable
    end

    # Set the behavior when downloading a file.
    struct SetDownloadBehavior
      include Protocol::Command
      include JSON::Serializable
    end

    # Overrides the Geolocation Position or Error. Omitting any of the parameters emulates position
    # unavailable.
    struct SetGeolocationOverride
      include Protocol::Command
      include JSON::Serializable
    end

    # Controls whether page will emit lifecycle events.
    struct SetLifecycleEventsEnabled
      include Protocol::Command
      include JSON::Serializable
    end

    # Toggles mouse event-based touch event emulation.
    struct SetTouchEmulationEnabled
      include Protocol::Command
      include JSON::Serializable
    end

    # Starts sending each frame using the `screencastFrame` event.
    struct StartScreencast
      include Protocol::Command
      include JSON::Serializable
    end

    # Force the page stop all navigations and pending resource fetches.
    struct StopLoading
      include Protocol::Command
      include JSON::Serializable
    end

    # Crashes renderer on the IO thread, generates minidumps.
    struct Crash
      include Protocol::Command
      include JSON::Serializable
    end

    # Tries to close page, running its beforeunload hooks, if any.
    struct Close
      include Protocol::Command
      include JSON::Serializable
    end

    # Tries to update the web lifecycle state of the page.
    # It will transition the page to the given state according to:
    # https://github.com/WICG/web-lifecycle/
    struct SetWebLifecycleState
      include Protocol::Command
      include JSON::Serializable
    end

    # Stops sending each frame in the `screencastFrame`.
    struct StopScreencast
      include Protocol::Command
      include JSON::Serializable
    end

    # Requests backend to produce compilation cache for the specified scripts.
    # `scripts` are appeneded to the list of scripts for which the cache
    # would be produced. The list may be reset during page navigation.
    # When script with a matching URL is encountered, the cache is optionally
    # produced upon backend discretion, based on internal heuristics.
    # See also: `Page.compilationCacheProduced`.
    struct ProduceCompilationCache
      include Protocol::Command
      include JSON::Serializable
    end

    # Seeds compilation cache for given url. Compilation cache does not survive
    # cross-process navigation.
    struct AddCompilationCache
      include Protocol::Command
      include JSON::Serializable
    end

    # Clears seeded compilation cache.
    struct ClearCompilationCache
      include Protocol::Command
      include JSON::Serializable
    end

    # Sets the Secure Payment Confirmation transaction mode.
    # https://w3c.github.io/secure-payment-confirmation/#sctn-automation-set-spc-transaction-mode
    struct SetSPCTransactionMode
      include Protocol::Command
      include JSON::Serializable
    end

    # Generates a report for testing.
    struct GenerateTestReport
      include Protocol::Command
      include JSON::Serializable
    end

    # Pauses page execution. Can be resumed using generic Runtime.runIfWaitingForDebugger.
    struct WaitForDebugger
      include Protocol::Command
      include JSON::Serializable
    end

    # Intercept file chooser requests and transfer control to protocol clients.
    # When file chooser interception is enabled, native file chooser dialog is not shown.
    # Instead, a protocol event `Page.fileChooserOpened` is emitted.
    struct SetInterceptFileChooserDialog
      include Protocol::Command
      include JSON::Serializable
    end

    # ----------------------------------------
    # Page Section: events
    # ----------------------------------------

    struct DomContentEventFired
      include JSON::Serializable
      include Protocol::Event
      getter timestamp : Network::MonotonicTime
    end

    # Emitted only when `page.interceptFileChooser` is enabled.
    struct FileChooserOpened
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "frameId")]
      # Id of the frame containing input node.
      getter frame_id : FrameId
      # Input mode.
      getter mode : String
      @[JSON::Field(key: "backendNodeId")]
      # Input node id. Only present for file choosers opened via an <input type="file"> element.
      getter backend_node_id : DOM::BackendNodeId?
    end

    # Fired when frame has been attached to its parent.
    struct FrameAttached
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "frameId")]
      # Id of the frame that has been attached.
      getter frame_id : FrameId
      @[JSON::Field(key: "parentFrameId")]
      # Parent frame identifier.
      getter parent_frame_id : FrameId
      # JavaScript stack trace of when frame was attached, only set if frame initiated from script.
      getter stack : Runtime::StackTrace?
    end

    # Fired when frame no longer has a scheduled navigation.
    struct FrameClearedScheduledNavigation
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "frameId")]
      # Id of the frame that has cleared its scheduled navigation.
      getter frame_id : FrameId
    end

    # Fired when frame has been detached from its parent.
    struct FrameDetached
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "frameId")]
      # Id of the frame that has been detached.
      getter frame_id : FrameId
      getter reason : String
    end

    # Fired once navigation of the frame has completed. Frame is now associated with the new loader.
    struct FrameNavigated
      include JSON::Serializable
      include Protocol::Event
      # Frame object.
      getter frame : Frame
      getter type : NavigationType
    end

    # Fired when opening document to write to.
    struct DocumentOpened
      include JSON::Serializable
      include Protocol::Event
      # Frame object.
      getter frame : Frame
    end

    struct FrameResized
      include JSON::Serializable
      include Protocol::Event
    end

    # Fired when a renderer-initiated navigation is requested.
    # Navigation may still be cancelled after the event is issued.
    struct FrameRequestedNavigation
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "frameId")]
      # Id of the frame that is being navigated.
      getter frame_id : FrameId
      # The reason for the navigation.
      getter reason : ClientNavigationReason
      # The destination URL for the requested navigation.
      getter url : String
      # The disposition for the navigation.
      getter disposition : ClientNavigationDisposition
    end

    # Fired when frame schedules a potential navigation.
    struct FrameScheduledNavigation
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "frameId")]
      # Id of the frame that has scheduled a navigation.
      getter frame_id : FrameId
      # Delay (in seconds) until the navigation is scheduled to begin. The navigation is not
      # guaranteed to start.
      getter delay : Number::Primitive
      # The reason for the navigation.
      getter reason : ClientNavigationReason
      # The destination URL for the scheduled navigation.
      getter url : String
    end

    # Fired when frame has started loading.
    struct FrameStartedLoading
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "frameId")]
      # Id of the frame that has started loading.
      getter frame_id : FrameId
    end

    # Fired when frame has stopped loading.
    struct FrameStoppedLoading
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "frameId")]
      # Id of the frame that has stopped loading.
      getter frame_id : FrameId
    end

    # Fired when page is about to start a download.
    # Deprecated. Use Browser.downloadWillBegin instead.
    struct DownloadWillBegin
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "frameId")]
      # Id of the frame that caused download to begin.
      getter frame_id : FrameId
      # Global unique identifier of the download.
      getter guid : String
      # URL of the resource being downloaded.
      getter url : String
      @[JSON::Field(key: "suggestedFilename")]
      # Suggested file name of the resource (the actual name of the file saved on disk may differ).
      getter suggested_filename : String
    end

    # Fired when download makes progress. Last call has |done| == true.
    # Deprecated. Use Browser.downloadProgress instead.
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

    # Fired when interstitial page was hidden
    struct InterstitialHidden
      include JSON::Serializable
      include Protocol::Event
    end

    # Fired when interstitial page was shown
    struct InterstitialShown
      include JSON::Serializable
      include Protocol::Event
    end

    # Fired when a JavaScript initiated dialog (alert, confirm, prompt, or onbeforeunload) has been
    # closed.
    struct JavascriptDialogClosed
      include JSON::Serializable
      include Protocol::Event
      # Whether dialog was confirmed.
      getter result : Bool
      @[JSON::Field(key: "userInput")]
      # User input in case of prompt.
      getter user_input : String
    end

    # Fired when a JavaScript initiated dialog (alert, confirm, prompt, or onbeforeunload) is about to
    # open.
    struct JavascriptDialogOpening
      include JSON::Serializable
      include Protocol::Event
      # Frame url.
      getter url : String
      # Message that will be displayed by the dialog.
      getter message : String
      # Dialog type.
      getter type : DialogType
      @[JSON::Field(key: "hasBrowserHandler")]
      # True iff browser is capable showing or acting on the given dialog. When browser has no
      # dialog handler for given target, calling alert while Page domain is engaged will stall
      # the page execution. Execution can be resumed via calling Page.handleJavaScriptDialog.
      getter has_browser_handler : Bool
      @[JSON::Field(key: "defaultPrompt")]
      # Default dialog prompt.
      getter default_prompt : String?
    end

    # Fired for top level page lifecycle events such as navigation, load, paint, etc.
    struct LifecycleEvent
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "frameId")]
      # Id of the frame.
      getter frame_id : FrameId
      @[JSON::Field(key: "loaderId")]
      # Loader identifier. Empty string if the request is fetched from worker.
      getter loader_id : Network::LoaderId
      getter name : String
      getter timestamp : Network::MonotonicTime
    end

    # Fired for failed bfcache history navigations if BackForwardCache feature is enabled. Do
    # not assume any ordering with the Page.frameNavigated event. This event is fired only for
    # main-frame history navigation where the document changes (non-same-document navigations),
    # when bfcache navigation fails.
    struct BackForwardCacheNotUsed
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "loaderId")]
      # The loader id for the associated navgation.
      getter loader_id : Network::LoaderId
      @[JSON::Field(key: "frameId")]
      # The frame id of the associated frame.
      getter frame_id : FrameId
      @[JSON::Field(key: "notRestoredExplanations")]
      # Array of reasons why the page could not be cached. This must not be empty.
      getter not_restored_explanations : Array(BackForwardCacheNotRestoredExplanation)
      @[JSON::Field(key: "notRestoredExplanationsTree")]
      # Tree structure of reasons why the page could not be cached for each frame.
      getter not_restored_explanations_tree : BackForwardCacheNotRestoredExplanationTree?
    end

    # Fired when a prerender attempt is completed.
    struct PrerenderAttemptCompleted
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "initiatingFrameId")]
      # The frame id of the frame initiating prerendering.
      getter initiating_frame_id : FrameId
      @[JSON::Field(key: "prerenderingUrl")]
      getter prerendering_url : String
      @[JSON::Field(key: "finalStatus")]
      getter final_status : PrerenderFinalStatus
      @[JSON::Field(key: "disallowedApiMethod")]
      # This is used to give users more information about the name of the API call
      # that is incompatible with prerender and has caused the cancellation of the attempt
      getter disallowed_api_method : String?
    end

    struct LoadEventFired
      include JSON::Serializable
      include Protocol::Event
      getter timestamp : Network::MonotonicTime
    end

    # Fired when same-document navigation happens, e.g. due to history API usage or anchor navigation.
    struct NavigatedWithinDocument
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "frameId")]
      # Id of the frame.
      getter frame_id : FrameId
      # Frame's new url.
      getter url : String
    end

    # Compressed image data requested by the `startScreencast`.
    struct ScreencastFrame
      include JSON::Serializable
      include Protocol::Event
      # Base64-encoded compressed image. (Encoded as a base64 string when passed over JSON)
      getter data : String
      # Screencast frame metadata.
      getter metadata : ScreencastFrameMetadata
      @[JSON::Field(key: "sessionId")]
      # Frame number.
      getter session_id : Int::Primitive
    end

    # Fired when the page with currently enabled screencast was shown or hidden `.
    struct ScreencastVisibilityChanged
      include JSON::Serializable
      include Protocol::Event
      # True if the page is visible.
      getter visible : Bool
    end

    # Fired when a new window is going to be opened, via window.open(), link click, form submission,
    # etc.
    struct WindowOpen
      include JSON::Serializable
      include Protocol::Event
      # The URL for the new window.
      getter url : String
      @[JSON::Field(key: "windowName")]
      # Window name.
      getter window_name : String
      @[JSON::Field(key: "windowFeatures")]
      # An array of enabled window features.
      getter window_features : Array(String)
      @[JSON::Field(key: "userGesture")]
      # Whether or not it was triggered by user gesture.
      getter user_gesture : Bool
    end

    # Issued for every compilation cache generated. Is only available
    # if Page.setGenerateCompilationCache is enabled.
    struct CompilationCacheProduced
      include JSON::Serializable
      include Protocol::Event
      getter url : String
      # Base64-encoded data (Encoded as a base64 string when passed over JSON)
      getter data : String
    end
  end
end
