# ================================================================================
# Audits domain allows investigation of page violations and possible improvements.
# ================================================================================

# Audits module dependencies
require "./network"

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module Audits
    # ----------------------------------------
    # Audits Section: types
    # ----------------------------------------

    # Information about a cookie that is affected by an inspector issue.
    struct AffectedCookie
      include JSON::Serializable
      # The following three properties uniquely identify a cookie
      getter name : String
      getter path : String
      getter domain : String
    end

    # Information about a request that is affected by an inspector issue.
    struct AffectedRequest
      include JSON::Serializable
      @[JSON::Field(key: "requestId")]
      # The unique request id.
      getter request_id : Network::RequestId
      getter url : String?
    end

    # Information about the frame affected by an inspector issue.
    struct AffectedFrame
      include JSON::Serializable
      @[JSON::Field(key: "frameId")]
      getter frame_id : Page::FrameId
    end

    enum CookieExclusionReason
      ExcludeSameSiteUnspecifiedTreatedAsLax # ExcludeSameSiteUnspecifiedTreatedAsLax
      ExcludeSameSiteNoneInsecure            # ExcludeSameSiteNoneInsecure
      ExcludeSameSiteLax                     # ExcludeSameSiteLax
      ExcludeSameSiteStrict                  # ExcludeSameSiteStrict
      ExcludeInvalidSameParty                # ExcludeInvalidSameParty
      ExcludeSamePartyCrossPartyContext      # ExcludeSamePartyCrossPartyContext
      ExcludeDomainNonASCII                  # ExcludeDomainNonASCII
    end

    enum CookieWarningReason
      WarnSameSiteUnspecifiedCrossSiteContext # WarnSameSiteUnspecifiedCrossSiteContext
      WarnSameSiteNoneInsecure                # WarnSameSiteNoneInsecure
      WarnSameSiteUnspecifiedLaxAllowUnsafe   # WarnSameSiteUnspecifiedLaxAllowUnsafe
      WarnSameSiteStrictLaxDowngradeStrict    # WarnSameSiteStrictLaxDowngradeStrict
      WarnSameSiteStrictCrossDowngradeStrict  # WarnSameSiteStrictCrossDowngradeStrict
      WarnSameSiteStrictCrossDowngradeLax     # WarnSameSiteStrictCrossDowngradeLax
      WarnSameSiteLaxCrossDowngradeStrict     # WarnSameSiteLaxCrossDowngradeStrict
      WarnSameSiteLaxCrossDowngradeLax        # WarnSameSiteLaxCrossDowngradeLax
      WarnAttributeValueExceedsMaxSize        # WarnAttributeValueExceedsMaxSize
      WarnDomainNonASCII                      # WarnDomainNonASCII
    end

    enum CookieOperation
      SetCookie  # SetCookie
      ReadCookie # ReadCookie
    end

    # This information is currently necessary, as the front-end has a difficult
    # time finding a specific cookie. With this, we can convey specific error
    # information without the cookie.
    struct CookieIssueDetails
      include JSON::Serializable
      # If AffectedCookie is not set then rawCookieLine contains the raw
      # Set-Cookie header string. This hints at a problem where the
      # cookie line is syntactically or semantically malformed in a way
      # that no valid cookie could be created.
      getter cookie : AffectedCookie?
      @[JSON::Field(key: "rawCookieLine")]
      getter raw_cookie_line : String?
      @[JSON::Field(key: "cookieWarningReasons")]
      getter cookie_warning_reasons : Array(CookieWarningReason)
      @[JSON::Field(key: "cookieExclusionReasons")]
      getter cookie_exclusion_reasons : Array(CookieExclusionReason)
      # Optionally identifies the site-for-cookies and the cookie url, which
      # may be used by the front-end as additional context.
      getter operation : CookieOperation
      @[JSON::Field(key: "siteForCookies")]
      getter site_for_cookies : String?
      @[JSON::Field(key: "cookieUrl")]
      getter cookie_url : String?
      getter request : AffectedRequest?
    end

    enum MixedContentResolutionStatus
      MixedContentBlocked               # MixedContentBlocked
      MixedContentAutomaticallyUpgraded # MixedContentAutomaticallyUpgraded
      MixedContentWarning               # MixedContentWarning
    end

    enum MixedContentResourceType
      AttributionSrc # AttributionSrc
      Audio          # Audio
      Beacon         # Beacon
      CSPReport      # CSPReport
      Download       # Download
      EventSource    # EventSource
      Favicon        # Favicon
      Font           # Font
      Form           # Form
      Frame          # Frame
      Image          # Image
      Import         # Import
      Manifest       # Manifest
      Ping           # Ping
      PluginData     # PluginData
      PluginResource # PluginResource
      Prefetch       # Prefetch
      Resource       # Resource
      Script         # Script
      ServiceWorker  # ServiceWorker
      SharedWorker   # SharedWorker
      Stylesheet     # Stylesheet
      Track          # Track
      Video          # Video
      Worker         # Worker
      XMLHttpRequest # XMLHttpRequest
      XSLT           # XSLT
    end

    struct MixedContentIssueDetails
      include JSON::Serializable
      @[JSON::Field(key: "resourceType")]
      # The type of resource causing the mixed content issue (css, js, iframe,
      # form,...). Marked as optional because it is mapped to from
      # blink::mojom::RequestContextType, which will be replaced
      # by network::mojom::RequestDestination
      getter resource_type : MixedContentResourceType?
      @[JSON::Field(key: "resolutionStatus")]
      # The way the mixed content issue is being resolved.
      getter resolution_status : MixedContentResolutionStatus
      @[JSON::Field(key: "insecureURL")]
      # The unsafe http url causing the mixed content issue.
      getter insecure_url : String
      @[JSON::Field(key: "mainResourceURL")]
      # The url responsible for the call to an unsafe url.
      getter main_resource_url : String
      # The mixed content request.
      # Does not always exist (e.g. for unsafe form submission urls).
      getter request : AffectedRequest?
      # Optional because not every mixed content issue is necessarily linked to a frame.
      getter frame : AffectedFrame?
    end

    # Enum indicating the reason a response has been blocked. These reasons are
    # refinements of the net error BLOCKED_BY_RESPONSE.
    enum BlockedByResponseReason
      CoepFrameResourceNeedsCoepHeader                  # CoepFrameResourceNeedsCoepHeader
      CoopSandboxedIFrameCannotNavigateToCoopPage       # CoopSandboxedIFrameCannotNavigateToCoopPage
      CorpNotSameOrigin                                 # CorpNotSameOrigin
      CorpNotSameOriginAfterDefaultedToSameOriginByCoep # CorpNotSameOriginAfterDefaultedToSameOriginByCoep
      CorpNotSameSite                                   # CorpNotSameSite
    end

    # Details for a request that has been blocked with the BLOCKED_BY_RESPONSE
    # code. Currently only used for COEP/COOP, but may be extended to include
    # some CSP errors in the future.
    struct BlockedByResponseIssueDetails
      include JSON::Serializable
      getter request : AffectedRequest
      @[JSON::Field(key: "parentFrame")]
      getter parent_frame : AffectedFrame?
      @[JSON::Field(key: "blockedFrame")]
      getter blocked_frame : AffectedFrame?
      getter reason : BlockedByResponseReason
    end

    enum HeavyAdResolutionStatus
      HeavyAdBlocked # HeavyAdBlocked
      HeavyAdWarning # HeavyAdWarning
    end

    enum HeavyAdReason
      NetworkTotalLimit # NetworkTotalLimit
      CpuTotalLimit     # CpuTotalLimit
      CpuPeakLimit      # CpuPeakLimit
    end

    struct HeavyAdIssueDetails
      include JSON::Serializable
      # The resolution status, either blocking the content or warning.
      getter resolution : HeavyAdResolutionStatus
      # The reason the ad was blocked, total network or cpu or peak cpu.
      getter reason : HeavyAdReason
      # The frame that was blocked.
      getter frame : AffectedFrame
    end

    enum ContentSecurityPolicyViolationType
      KInlineViolation             # kInlineViolation
      KEvalViolation               # kEvalViolation
      KURLViolation                # kURLViolation
      KTrustedTypesSinkViolation   # kTrustedTypesSinkViolation
      KTrustedTypesPolicyViolation # kTrustedTypesPolicyViolation
      KWasmEvalViolation           # kWasmEvalViolation
    end

    struct SourceCodeLocation
      include JSON::Serializable
      @[JSON::Field(key: "scriptId")]
      getter script_id : Runtime::ScriptId?
      getter url : String
      @[JSON::Field(key: "lineNumber")]
      getter line_number : Int::Primitive
      @[JSON::Field(key: "columnNumber")]
      getter column_number : Int::Primitive
    end

    struct ContentSecurityPolicyIssueDetails
      include JSON::Serializable
      @[JSON::Field(key: "blockedURL")]
      # The url not included in allowed sources.
      getter blocked_url : String?
      @[JSON::Field(key: "violatedDirective")]
      # Specific directive that is violated, causing the CSP issue.
      getter violated_directive : String
      @[JSON::Field(key: "isReportOnly")]
      getter is_report_only : Bool
      @[JSON::Field(key: "contentSecurityPolicyViolationType")]
      getter content_security_policy_violation_type : ContentSecurityPolicyViolationType
      @[JSON::Field(key: "frameAncestor")]
      getter frame_ancestor : AffectedFrame?
      @[JSON::Field(key: "sourceCodeLocation")]
      getter source_code_location : SourceCodeLocation?
      @[JSON::Field(key: "violatingNodeId")]
      getter violating_node_id : DOM::BackendNodeId?
    end

    enum SharedArrayBufferIssueType
      TransferIssue # TransferIssue
      CreationIssue # CreationIssue
    end

    # Details for a issue arising from an SAB being instantiated in, or
    # transferred to a context that is not cross-origin isolated.
    struct SharedArrayBufferIssueDetails
      include JSON::Serializable
      @[JSON::Field(key: "sourceCodeLocation")]
      getter source_code_location : SourceCodeLocation
      @[JSON::Field(key: "isWarning")]
      getter is_warning : Bool
      getter type : SharedArrayBufferIssueType
    end

    enum TwaQualityEnforcementViolationType
      KHttpError          # kHttpError
      KUnavailableOffline # kUnavailableOffline
      KDigitalAssetLinks  # kDigitalAssetLinks
    end

    struct TrustedWebActivityIssueDetails
      include JSON::Serializable
      # The url that triggers the violation.
      getter url : String
      @[JSON::Field(key: "violationType")]
      getter violation_type : TwaQualityEnforcementViolationType
      @[JSON::Field(key: "httpStatusCode")]
      getter http_status_code : Int::Primitive?
      @[JSON::Field(key: "packageName")]
      # The package name of the Trusted Web Activity client app. This field is
      # only used when violation type is kDigitalAssetLinks.
      getter package_name : String?
      # The signature of the Trusted Web Activity client app. This field is only
      # used when violation type is kDigitalAssetLinks.
      getter signature : String?
    end

    struct LowTextContrastIssueDetails
      include JSON::Serializable
      @[JSON::Field(key: "violatingNodeId")]
      getter violating_node_id : DOM::BackendNodeId
      @[JSON::Field(key: "violatingNodeSelector")]
      getter violating_node_selector : String
      @[JSON::Field(key: "contrastRatio")]
      getter contrast_ratio : Number::Primitive
      @[JSON::Field(key: "thresholdAA")]
      getter threshold_aa : Number::Primitive
      @[JSON::Field(key: "thresholdAAA")]
      getter threshold_aaa : Number::Primitive
      @[JSON::Field(key: "fontSize")]
      getter font_size : String
      @[JSON::Field(key: "fontWeight")]
      getter font_weight : String
    end

    # Details for a CORS related issue, e.g. a warning or error related to
    # CORS RFC1918 enforcement.
    struct CorsIssueDetails
      include JSON::Serializable
      @[JSON::Field(key: "corsErrorStatus")]
      getter cors_error_status : Network::CorsErrorStatus
      @[JSON::Field(key: "isWarning")]
      getter is_warning : Bool
      getter request : AffectedRequest
      getter location : SourceCodeLocation?
      @[JSON::Field(key: "initiatorOrigin")]
      getter initiator_origin : String?
      @[JSON::Field(key: "resourceIPAddressSpace")]
      getter resource_ip_address_space : Network::IPAddressSpace?
      @[JSON::Field(key: "clientSecurityState")]
      getter client_security_state : Network::ClientSecurityState?
    end

    enum AttributionReportingIssueType
      PermissionPolicyDisabled     # PermissionPolicyDisabled
      PermissionPolicyNotDelegated # PermissionPolicyNotDelegated
      UntrustworthyReportingOrigin # UntrustworthyReportingOrigin
      InsecureContext              # InsecureContext
      InvalidHeader                # InvalidHeader
      InvalidRegisterTriggerHeader # InvalidRegisterTriggerHeader
      InvalidEligibleHeader        # InvalidEligibleHeader
      TooManyConcurrentRequests    # TooManyConcurrentRequests
      SourceAndTriggerHeaders      # SourceAndTriggerHeaders
      SourceIgnored                # SourceIgnored
      TriggerIgnored               # TriggerIgnored
    end

    # Details for issues around "Attribution Reporting API" usage.
    # Explainer: https://github.com/WICG/attribution-reporting-api
    struct AttributionReportingIssueDetails
      include JSON::Serializable
      @[JSON::Field(key: "violationType")]
      getter violation_type : AttributionReportingIssueType
      getter request : AffectedRequest?
      @[JSON::Field(key: "violatingNodeId")]
      getter violating_node_id : DOM::BackendNodeId?
      @[JSON::Field(key: "invalidParameter")]
      getter invalid_parameter : String?
    end

    # Details for issues about documents in Quirks Mode
    # or Limited Quirks Mode that affects page layouting.
    struct QuirksModeIssueDetails
      include JSON::Serializable
      @[JSON::Field(key: "isLimitedQuirksMode")]
      # If false, it means the document's mode is "quirks"
      # instead of "limited-quirks".
      getter is_limited_quirks_mode : Bool
      @[JSON::Field(key: "documentNodeId")]
      getter document_node_id : DOM::BackendNodeId
      getter url : String
      @[JSON::Field(key: "frameId")]
      getter frame_id : Page::FrameId
      @[JSON::Field(key: "loaderId")]
      getter loader_id : Network::LoaderId
    end

    struct NavigatorUserAgentIssueDetails
      include JSON::Serializable
      getter url : String
      getter location : SourceCodeLocation?
    end

    enum GenericIssueErrorType
      CrossOriginPortalPostMessageError # CrossOriginPortalPostMessageError
    end

    # Depending on the concrete errorType, different properties are set.
    struct GenericIssueDetails
      include JSON::Serializable
      @[JSON::Field(key: "errorType")]
      # Issues with the same errorType are aggregated in the frontend.
      getter error_type : GenericIssueErrorType
      @[JSON::Field(key: "frameId")]
      getter frame_id : Page::FrameId?
    end

    enum DeprecationIssueType
      AuthorizationCoveredByWildcard                            # AuthorizationCoveredByWildcard
      CanRequestURLHTTPContainingNewline                        # CanRequestURLHTTPContainingNewline
      ChromeLoadTimesConnectionInfo                             # ChromeLoadTimesConnectionInfo
      ChromeLoadTimesFirstPaintAfterLoadTime                    # ChromeLoadTimesFirstPaintAfterLoadTime
      ChromeLoadTimesWasAlternateProtocolAvailable              # ChromeLoadTimesWasAlternateProtocolAvailable
      CookieWithTruncatingChar                                  # CookieWithTruncatingChar
      CrossOriginAccessBasedOnDocumentDomain                    # CrossOriginAccessBasedOnDocumentDomain
      CrossOriginWindowAlert                                    # CrossOriginWindowAlert
      CrossOriginWindowConfirm                                  # CrossOriginWindowConfirm
      CSSSelectorInternalMediaControlsOverlayCastButton         # CSSSelectorInternalMediaControlsOverlayCastButton
      DeprecationExample                                        # DeprecationExample
      DocumentDomainSettingWithoutOriginAgentClusterHeader      # DocumentDomainSettingWithoutOriginAgentClusterHeader
      EventPath                                                 # EventPath
      ExpectCTHeader                                            # ExpectCTHeader
      GeolocationInsecureOrigin                                 # GeolocationInsecureOrigin
      GeolocationInsecureOriginDeprecatedNotRemoved             # GeolocationInsecureOriginDeprecatedNotRemoved
      GetUserMediaInsecureOrigin                                # GetUserMediaInsecureOrigin
      HostCandidateAttributeGetter                              # HostCandidateAttributeGetter
      IdentityInCanMakePaymentEvent                             # IdentityInCanMakePaymentEvent
      InsecurePrivateNetworkSubresourceRequest                  # InsecurePrivateNetworkSubresourceRequest
      LocalCSSFileExtensionRejected                             # LocalCSSFileExtensionRejected
      MediaSourceAbortRemove                                    # MediaSourceAbortRemove
      MediaSourceDurationTruncatingBuffered                     # MediaSourceDurationTruncatingBuffered
      NoSysexWebMIDIWithoutPermission                           # NoSysexWebMIDIWithoutPermission
      NotificationInsecureOrigin                                # NotificationInsecureOrigin
      NotificationPermissionRequestedIframe                     # NotificationPermissionRequestedIframe
      ObsoleteWebRtcCipherSuite                                 # ObsoleteWebRtcCipherSuite
      OpenWebDatabaseInsecureContext                            # OpenWebDatabaseInsecureContext
      OverflowVisibleOnReplacedElement                          # OverflowVisibleOnReplacedElement
      PaymentInstruments                                        # PaymentInstruments
      PaymentRequestCSPViolation                                # PaymentRequestCSPViolation
      PersistentQuotaType                                       # PersistentQuotaType
      PictureSourceSrc                                          # PictureSourceSrc
      PrefixedCancelAnimationFrame                              # PrefixedCancelAnimationFrame
      PrefixedRequestAnimationFrame                             # PrefixedRequestAnimationFrame
      PrefixedStorageInfo                                       # PrefixedStorageInfo
      PrefixedVideoDisplayingFullscreen                         # PrefixedVideoDisplayingFullscreen
      PrefixedVideoEnterFullscreen                              # PrefixedVideoEnterFullscreen
      PrefixedVideoEnterFullScreen                              # PrefixedVideoEnterFullScreen
      PrefixedVideoExitFullscreen                               # PrefixedVideoExitFullscreen
      PrefixedVideoExitFullScreen                               # PrefixedVideoExitFullScreen
      PrefixedVideoSupportsFullscreen                           # PrefixedVideoSupportsFullscreen
      RangeExpand                                               # RangeExpand
      RequestedSubresourceWithEmbeddedCredentials               # RequestedSubresourceWithEmbeddedCredentials
      RTCConstraintEnableDtlsSrtpFalse                          # RTCConstraintEnableDtlsSrtpFalse
      RTCConstraintEnableDtlsSrtpTrue                           # RTCConstraintEnableDtlsSrtpTrue
      RTCPeerConnectionComplexPlanBSdpUsingDefaultSdpSemantics  # RTCPeerConnectionComplexPlanBSdpUsingDefaultSdpSemantics
      RTCPeerConnectionSdpSemanticsPlanB                        # RTCPeerConnectionSdpSemanticsPlanB
      RtcpMuxPolicyNegotiate                                    # RtcpMuxPolicyNegotiate
      SharedArrayBufferConstructedWithoutIsolation              # SharedArrayBufferConstructedWithoutIsolation
      TextToSpeechDisallowedByAutoplay                          # TextToSpeech_DisallowedByAutoplay
      V8SharedArrayBufferConstructedInExtensionWithoutIsolation # V8SharedArrayBufferConstructedInExtensionWithoutIsolation
      XHRJSONEncodingDetection                                  # XHRJSONEncodingDetection
      XMLHttpRequestSynchronousInNonWorkerOutsideBeforeUnload   # XMLHttpRequestSynchronousInNonWorkerOutsideBeforeUnload
      XRSupportsSession                                         # XRSupportsSession
    end

    # This issue tracks information needed to print a deprecation message.
    # https://source.chromium.org/chromium/chromium/src/+/main:third_party/blink/renderer/core/frame/third_party/blink/renderer/core/frame/deprecation/README.md
    struct DeprecationIssueDetails
      include JSON::Serializable
      @[JSON::Field(key: "affectedFrame")]
      getter affected_frame : AffectedFrame?
      @[JSON::Field(key: "sourceCodeLocation")]
      getter source_code_location : SourceCodeLocation
      getter type : DeprecationIssueType
    end

    enum ClientHintIssueReason
      MetaTagAllowListInvalidOrigin # MetaTagAllowListInvalidOrigin
      MetaTagModifiedHTML           # MetaTagModifiedHTML
    end

    struct FederatedAuthRequestIssueDetails
      include JSON::Serializable
      @[JSON::Field(key: "federatedAuthRequestIssueReason")]
      getter federated_auth_request_issue_reason : FederatedAuthRequestIssueReason
    end

    # Represents the failure reason when a federated authentication reason fails.
    # Should be updated alongside RequestIdTokenStatus in
    # third_party/blink/public/mojom/devtools/inspector_issue.mojom to include
    # all cases except for success.
    enum FederatedAuthRequestIssueReason
      ShouldEmbargo                 # ShouldEmbargo
      TooManyRequests               # TooManyRequests
      ManifestListHttpNotFound      # ManifestListHttpNotFound
      ManifestListNoResponse        # ManifestListNoResponse
      ManifestListInvalidResponse   # ManifestListInvalidResponse
      ManifestNotInManifestList     # ManifestNotInManifestList
      ManifestListTooBig            # ManifestListTooBig
      ManifestHttpNotFound          # ManifestHttpNotFound
      ManifestNoResponse            # ManifestNoResponse
      ManifestInvalidResponse       # ManifestInvalidResponse
      ClientMetadataHttpNotFound    # ClientMetadataHttpNotFound
      ClientMetadataNoResponse      # ClientMetadataNoResponse
      ClientMetadataInvalidResponse # ClientMetadataInvalidResponse
      DisabledInSettings            # DisabledInSettings
      ErrorFetchingSignin           # ErrorFetchingSignin
      InvalidSigninResponse         # InvalidSigninResponse
      AccountsHttpNotFound          # AccountsHttpNotFound
      AccountsNoResponse            # AccountsNoResponse
      AccountsInvalidResponse       # AccountsInvalidResponse
      IdTokenHttpNotFound           # IdTokenHttpNotFound
      IdTokenNoResponse             # IdTokenNoResponse
      IdTokenInvalidResponse        # IdTokenInvalidResponse
      IdTokenInvalidRequest         # IdTokenInvalidRequest
      ErrorIdToken                  # ErrorIdToken
      Canceled                      # Canceled
      RpPageNotVisible              # RpPageNotVisible
    end

    # This issue tracks client hints related issues. It's used to deprecate old
    # features, encourage the use of new ones, and provide general guidance.
    struct ClientHintIssueDetails
      include JSON::Serializable
      @[JSON::Field(key: "sourceCodeLocation")]
      getter source_code_location : SourceCodeLocation
      @[JSON::Field(key: "clientHintIssueReason")]
      getter client_hint_issue_reason : ClientHintIssueReason
    end

    # A unique identifier for the type of issue. Each type may use one of the
    # optional fields in InspectorIssueDetails to convey more specific
    # information about the kind of issue.
    enum InspectorIssueCode
      CookieIssue                # CookieIssue
      MixedContentIssue          # MixedContentIssue
      BlockedByResponseIssue     # BlockedByResponseIssue
      HeavyAdIssue               # HeavyAdIssue
      ContentSecurityPolicyIssue # ContentSecurityPolicyIssue
      SharedArrayBufferIssue     # SharedArrayBufferIssue
      TrustedWebActivityIssue    # TrustedWebActivityIssue
      LowTextContrastIssue       # LowTextContrastIssue
      CorsIssue                  # CorsIssue
      AttributionReportingIssue  # AttributionReportingIssue
      QuirksModeIssue            # QuirksModeIssue
      NavigatorUserAgentIssue    # NavigatorUserAgentIssue
      GenericIssue               # GenericIssue
      DeprecationIssue           # DeprecationIssue
      ClientHintIssue            # ClientHintIssue
      FederatedAuthRequestIssue  # FederatedAuthRequestIssue
    end

    # This struct holds a list of optional fields with additional information
    # specific to the kind of issue. When adding a new issue code, please also
    # add a new optional field to this type.
    struct InspectorIssueDetails
      include JSON::Serializable
      @[JSON::Field(key: "cookieIssueDetails")]
      getter cookie_issue_details : CookieIssueDetails?
      @[JSON::Field(key: "mixedContentIssueDetails")]
      getter mixed_content_issue_details : MixedContentIssueDetails?
      @[JSON::Field(key: "blockedByResponseIssueDetails")]
      getter blocked_by_response_issue_details : BlockedByResponseIssueDetails?
      @[JSON::Field(key: "heavyAdIssueDetails")]
      getter heavy_ad_issue_details : HeavyAdIssueDetails?
      @[JSON::Field(key: "contentSecurityPolicyIssueDetails")]
      getter content_security_policy_issue_details : ContentSecurityPolicyIssueDetails?
      @[JSON::Field(key: "sharedArrayBufferIssueDetails")]
      getter shared_array_buffer_issue_details : SharedArrayBufferIssueDetails?
      @[JSON::Field(key: "twaQualityEnforcementDetails")]
      getter twa_quality_enforcement_details : TrustedWebActivityIssueDetails?
      @[JSON::Field(key: "lowTextContrastIssueDetails")]
      getter low_text_contrast_issue_details : LowTextContrastIssueDetails?
      @[JSON::Field(key: "corsIssueDetails")]
      getter cors_issue_details : CorsIssueDetails?
      @[JSON::Field(key: "attributionReportingIssueDetails")]
      getter attribution_reporting_issue_details : AttributionReportingIssueDetails?
      @[JSON::Field(key: "quirksModeIssueDetails")]
      getter quirks_mode_issue_details : QuirksModeIssueDetails?
      @[JSON::Field(key: "navigatorUserAgentIssueDetails")]
      getter navigator_user_agent_issue_details : NavigatorUserAgentIssueDetails?
      @[JSON::Field(key: "genericIssueDetails")]
      getter generic_issue_details : GenericIssueDetails?
      @[JSON::Field(key: "deprecationIssueDetails")]
      getter deprecation_issue_details : DeprecationIssueDetails?
      @[JSON::Field(key: "clientHintIssueDetails")]
      getter client_hint_issue_details : ClientHintIssueDetails?
      @[JSON::Field(key: "federatedAuthRequestIssueDetails")]
      getter federated_auth_request_issue_details : FederatedAuthRequestIssueDetails?
    end

    # A unique id for a DevTools inspector issue. Allows other entities (e.g.
    # exceptions, CDP message, console messages, etc.) to reference an issue.
    alias IssueId = String

    # An inspector issue reported from the back-end.
    struct InspectorIssue
      include JSON::Serializable
      getter code : InspectorIssueCode
      getter details : InspectorIssueDetails
      @[JSON::Field(key: "issueId")]
      # A unique id for this issue. May be omitted if no other entity (e.g.
      # exception, CDP message, etc.) is referencing this issue.
      getter issue_id : IssueId?
    end

    # ----------------------------------------
    # Audits Section: commands
    # ----------------------------------------

    # Returns the response body and size if it were re-encoded with the specified settings. Only
    # applies to images.
    struct GetEncodedResponse
      include Protocol::Command
      include JSON::Serializable
      # The encoded body as a base64 string. Omitted if sizeOnly is true. (Encoded as a base64 string when passed over JSON)
      getter body : String?
      @[JSON::Field(key: "originalSize")]
      # Size before re-encoding.
      getter original_size : Int::Primitive
      @[JSON::Field(key: "encodedSize")]
      # Size after re-encoding.
      getter encoded_size : Int::Primitive
    end

    # Disables issues domain, prevents further issues from being reported to the client.
    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    # Enables issues domain, sends the issues collected so far to the client by means of the
    # `issueAdded` event.
    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    # Runs the contrast check for the target page. Found issues are reported
    # using Audits.issueAdded event.
    struct CheckContrast
      include Protocol::Command
      include JSON::Serializable
    end

    # ----------------------------------------
    # Audits Section: events
    # ----------------------------------------

    struct IssueAdded
      include JSON::Serializable
      include Protocol::Event
      getter issue : InspectorIssue
    end
  end
end
