# ================================================================================
# Network domain allows tracking network activities of the page. It exposes information about http,
# file, data and other requests and responses, their headers, bodies, timing, etc.
# ================================================================================

# Network module dependencies
require "./debugger"
require "./runtime"
require "./security"

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module Network
    # ----------------------------------------
    # Network Section: types
    # ----------------------------------------

    # Resource type as it was perceived by the rendering engine.
    enum ResourceType
      Document           # Document
      Stylesheet         # Stylesheet
      Image              # Image
      Media              # Media
      Font               # Font
      Script             # Script
      TextTrack          # TextTrack
      XHR                # XHR
      Fetch              # Fetch
      Prefetch           # Prefetch
      EventSource        # EventSource
      WebSocket          # WebSocket
      Manifest           # Manifest
      SignedExchange     # SignedExchange
      Ping               # Ping
      CSPViolationReport # CSPViolationReport
      Preflight          # Preflight
      Other              # Other
    end

    # Unique loader identifier.
    alias LoaderId = String

    # Unique request identifier.
    alias RequestId = String

    # Unique intercepted request identifier.
    alias InterceptionId = String

    # Network level fetch failure reason.
    enum ErrorReason
      Failed               # Failed
      Aborted              # Aborted
      TimedOut             # TimedOut
      AccessDenied         # AccessDenied
      ConnectionClosed     # ConnectionClosed
      ConnectionReset      # ConnectionReset
      ConnectionRefused    # ConnectionRefused
      ConnectionAborted    # ConnectionAborted
      ConnectionFailed     # ConnectionFailed
      NameNotResolved      # NameNotResolved
      InternetDisconnected # InternetDisconnected
      AddressUnreachable   # AddressUnreachable
      BlockedByClient      # BlockedByClient
      BlockedByResponse    # BlockedByResponse
    end

    # UTC time in seconds, counted from January 1, 1970.
    alias TimeSinceEpoch = Number::Primitive

    # Monotonically increasing time in seconds since an arbitrary point in the past.
    alias MonotonicTime = Number::Primitive

    # Request / response headers as keys / values of JSON object.
    struct Headers
      include JSON::Serializable
    end

    # The underlying connection technology that the browser is supposedly using.
    enum ConnectionType
      None       # none
      Cellular2g # cellular2g
      Cellular3g # cellular3g
      Cellular4g # cellular4g
      Bluetooth  # bluetooth
      Ethernet   # ethernet
      Wifi       # wifi
      Wimax      # wimax
      Other      # other
    end

    # Represents the cookie's 'SameSite' status:
    # https://tools.ietf.org/html/draft-west-first-party-cookies
    enum CookieSameSite
      Strict # Strict
      Lax    # Lax
      None   # None
    end

    # Represents the cookie's 'Priority' status:
    # https://tools.ietf.org/html/draft-west-cookie-priority-00
    enum CookiePriority
      Low    # Low
      Medium # Medium
      High   # High
    end

    # Represents the source scheme of the origin that originally set the cookie.
    # A value of "Unset" allows protocol clients to emulate legacy cookie scope for the scheme.
    # This is a temporary ability and it will be removed in the future.
    enum CookieSourceScheme
      Unset     # Unset
      NonSecure # NonSecure
      Secure    # Secure
    end

    # Timing information for the request.
    struct ResourceTiming
      include JSON::Serializable
      @[JSON::Field(key: "requestTime")]
      # Timing's requestTime is a baseline in seconds, while the other numbers are ticks in
      # milliseconds relatively to this requestTime.
      getter request_time : Number::Primitive
      @[JSON::Field(key: "proxyStart")]
      # Started resolving proxy.
      getter proxy_start : Number::Primitive
      @[JSON::Field(key: "proxyEnd")]
      # Finished resolving proxy.
      getter proxy_end : Number::Primitive
      @[JSON::Field(key: "dnsStart")]
      # Started DNS address resolve.
      getter dns_start : Number::Primitive
      @[JSON::Field(key: "dnsEnd")]
      # Finished DNS address resolve.
      getter dns_end : Number::Primitive
      @[JSON::Field(key: "connectStart")]
      # Started connecting to the remote host.
      getter connect_start : Number::Primitive
      @[JSON::Field(key: "connectEnd")]
      # Connected to the remote host.
      getter connect_end : Number::Primitive
      @[JSON::Field(key: "sslStart")]
      # Started SSL handshake.
      getter ssl_start : Number::Primitive
      @[JSON::Field(key: "sslEnd")]
      # Finished SSL handshake.
      getter ssl_end : Number::Primitive
      @[JSON::Field(key: "workerStart")]
      # Started running ServiceWorker.
      getter worker_start : Number::Primitive
      @[JSON::Field(key: "workerReady")]
      # Finished Starting ServiceWorker.
      getter worker_ready : Number::Primitive
      @[JSON::Field(key: "workerFetchStart")]
      # Started fetch event.
      getter worker_fetch_start : Number::Primitive
      @[JSON::Field(key: "workerRespondWithSettled")]
      # Settled fetch event respondWith promise.
      getter worker_respond_with_settled : Number::Primitive
      @[JSON::Field(key: "sendStart")]
      # Started sending request.
      getter send_start : Number::Primitive
      @[JSON::Field(key: "sendEnd")]
      # Finished sending request.
      getter send_end : Number::Primitive
      @[JSON::Field(key: "pushStart")]
      # Time the server started pushing request.
      getter push_start : Number::Primitive
      @[JSON::Field(key: "pushEnd")]
      # Time the server finished pushing request.
      getter push_end : Number::Primitive
      @[JSON::Field(key: "receiveHeadersEnd")]
      # Finished receiving response headers.
      getter receive_headers_end : Number::Primitive
    end

    # Loading priority of a resource request.
    enum ResourcePriority
      VeryLow  # VeryLow
      Low      # Low
      Medium   # Medium
      High     # High
      VeryHigh # VeryHigh
    end

    # Post data entry for HTTP request
    struct PostDataEntry
      include JSON::Serializable
      getter bytes : String?
    end

    # HTTP request data.
    struct Request
      include JSON::Serializable
      # Request URL (without fragment).
      getter url : String
      @[JSON::Field(key: "urlFragment")]
      # Fragment of the requested URL starting with hash, if present.
      getter url_fragment : String?
      # HTTP request method.
      getter method : String
      # HTTP request headers.
      getter headers : Headers
      @[JSON::Field(key: "postData")]
      # HTTP POST request data.
      getter post_data : String?
      @[JSON::Field(key: "hasPostData")]
      # True when the request has POST data. Note that postData might still be omitted when this flag is true when the data is too long.
      getter has_post_data : Bool?
      @[JSON::Field(key: "postDataEntries")]
      # Request body elements. This will be converted from base64 to binary
      getter post_data_entries : Array(PostDataEntry)?
      @[JSON::Field(key: "mixedContentType")]
      # The mixed content type of the request.
      getter mixed_content_type : Security::MixedContentType?
      @[JSON::Field(key: "initialPriority")]
      # Priority of the resource request at the time request is sent.
      getter initial_priority : ResourcePriority
      @[JSON::Field(key: "referrerPolicy")]
      # The referrer policy of the request, as defined in https://www.w3.org/TR/referrer-policy/
      getter referrer_policy : String
      @[JSON::Field(key: "isLinkPreload")]
      # Whether is loaded via link preload.
      getter is_link_preload : Bool?
      @[JSON::Field(key: "trustTokenParams")]
      # Set for requests when the TrustToken API is used. Contains the parameters
      # passed by the developer (e.g. via "fetch") as understood by the backend.
      getter trust_token_params : TrustTokenParams?
      @[JSON::Field(key: "isSameSite")]
      # True if this resource request is considered to be the 'same site' as the
      # request correspondinfg to the main frame.
      getter is_same_site : Bool?
    end

    # Details of a signed certificate timestamp (SCT).
    struct SignedCertificateTimestamp
      include JSON::Serializable
      # Validation status.
      getter status : String
      # Origin.
      getter origin : String
      @[JSON::Field(key: "logDescription")]
      # Log name / description.
      getter log_description : String
      @[JSON::Field(key: "logId")]
      # Log ID.
      getter log_id : String
      # Issuance date. Unlike TimeSinceEpoch, this contains the number of
      # milliseconds since January 1, 1970, UTC, not the number of seconds.
      getter timestamp : Number::Primitive
      @[JSON::Field(key: "hashAlgorithm")]
      # Hash algorithm.
      getter hash_algorithm : String
      @[JSON::Field(key: "signatureAlgorithm")]
      # Signature algorithm.
      getter signature_algorithm : String
      @[JSON::Field(key: "signatureData")]
      # Signature data.
      getter signature_data : String
    end

    # Security details about a request.
    struct SecurityDetails
      include JSON::Serializable
      # Protocol name (e.g. "TLS 1.2" or "QUIC").
      getter protocol : String
      @[JSON::Field(key: "keyExchange")]
      # Key Exchange used by the connection, or the empty string if not applicable.
      getter key_exchange : String
      @[JSON::Field(key: "keyExchangeGroup")]
      # (EC)DH group used by the connection, if applicable.
      getter key_exchange_group : String?
      # Cipher name.
      getter cipher : String
      # TLS MAC. Note that AEAD ciphers do not have separate MACs.
      getter mac : String?
      @[JSON::Field(key: "certificateId")]
      # Certificate ID value.
      getter certificate_id : Security::CertificateId
      @[JSON::Field(key: "subjectName")]
      # Certificate subject name.
      getter subject_name : String
      @[JSON::Field(key: "sanList")]
      # Subject Alternative Name (SAN) DNS names and IP addresses.
      getter san_list : Array(String)
      # Name of the issuing CA.
      getter issuer : String
      @[JSON::Field(key: "validFrom")]
      # Certificate valid from date.
      getter valid_from : TimeSinceEpoch
      @[JSON::Field(key: "validTo")]
      # Certificate valid to (expiration) date
      getter valid_to : TimeSinceEpoch
      @[JSON::Field(key: "signedCertificateTimestampList")]
      # List of signed certificate timestamps (SCTs).
      getter signed_certificate_timestamp_list : Array(SignedCertificateTimestamp)
      @[JSON::Field(key: "certificateTransparencyCompliance")]
      # Whether the request complied with Certificate Transparency policy
      getter certificate_transparency_compliance : CertificateTransparencyCompliance
      @[JSON::Field(key: "serverSignatureAlgorithm")]
      # The signature algorithm used by the server in the TLS server signature,
      # represented as a TLS SignatureScheme code point. Omitted if not
      # applicable or not known.
      getter server_signature_algorithm : Int::Primitive?
      @[JSON::Field(key: "encryptedClientHello")]
      # Whether the connection used Encrypted ClientHello
      getter encrypted_client_hello : Bool
    end

    # Whether the request complied with Certificate Transparency policy.
    @[DashEnum]
    enum CertificateTransparencyCompliance
      Unknown      # unknown
      NotCompliant # not-compliant
      Compliant    # compliant
    end

    # The reason why request was blocked.
    @[DashEnum]
    enum BlockedReason
      Other                                             # other
      Csp                                               # csp
      MixedContent                                      # mixed-content
      Origin                                            # origin
      Inspector                                         # inspector
      SubresourceFilter                                 # subresource-filter
      ContentType                                       # content-type
      CoepFrameResourceNeedsCoepHeader                  # coep-frame-resource-needs-coep-header
      CoopSandboxedIframeCannotNavigateToCoopPage       # coop-sandboxed-iframe-cannot-navigate-to-coop-page
      CorpNotSameOrigin                                 # corp-not-same-origin
      CorpNotSameOriginAfterDefaultedToSameOriginByCoep # corp-not-same-origin-after-defaulted-to-same-origin-by-coep
      CorpNotSameSite                                   # corp-not-same-site
    end

    # The reason why request was blocked.
    enum CorsError
      DisallowedByMode                     # DisallowedByMode
      InvalidResponse                      # InvalidResponse
      WildcardOriginNotAllowed             # WildcardOriginNotAllowed
      MissingAllowOriginHeader             # MissingAllowOriginHeader
      MultipleAllowOriginValues            # MultipleAllowOriginValues
      InvalidAllowOriginValue              # InvalidAllowOriginValue
      AllowOriginMismatch                  # AllowOriginMismatch
      InvalidAllowCredentials              # InvalidAllowCredentials
      CorsDisabledScheme                   # CorsDisabledScheme
      PreflightInvalidStatus               # PreflightInvalidStatus
      PreflightDisallowedRedirect          # PreflightDisallowedRedirect
      PreflightWildcardOriginNotAllowed    # PreflightWildcardOriginNotAllowed
      PreflightMissingAllowOriginHeader    # PreflightMissingAllowOriginHeader
      PreflightMultipleAllowOriginValues   # PreflightMultipleAllowOriginValues
      PreflightInvalidAllowOriginValue     # PreflightInvalidAllowOriginValue
      PreflightAllowOriginMismatch         # PreflightAllowOriginMismatch
      PreflightInvalidAllowCredentials     # PreflightInvalidAllowCredentials
      PreflightMissingAllowExternal        # PreflightMissingAllowExternal
      PreflightInvalidAllowExternal        # PreflightInvalidAllowExternal
      PreflightMissingAllowPrivateNetwork  # PreflightMissingAllowPrivateNetwork
      PreflightInvalidAllowPrivateNetwork  # PreflightInvalidAllowPrivateNetwork
      InvalidAllowMethodsPreflightResponse # InvalidAllowMethodsPreflightResponse
      InvalidAllowHeadersPreflightResponse # InvalidAllowHeadersPreflightResponse
      MethodDisallowedByPreflightResponse  # MethodDisallowedByPreflightResponse
      HeaderDisallowedByPreflightResponse  # HeaderDisallowedByPreflightResponse
      RedirectContainsCredentials          # RedirectContainsCredentials
      InsecurePrivateNetwork               # InsecurePrivateNetwork
      InvalidPrivateNetworkAccess          # InvalidPrivateNetworkAccess
      UnexpectedPrivateNetworkAccess       # UnexpectedPrivateNetworkAccess
      NoCorsRedirectModeNotFollow          # NoCorsRedirectModeNotFollow
    end

    struct CorsErrorStatus
      include JSON::Serializable
      @[JSON::Field(key: "corsError")]
      getter cors_error : CorsError
      @[JSON::Field(key: "failedParameter")]
      getter failed_parameter : String
    end

    # Source of serviceworker response.
    @[DashEnum]
    enum ServiceWorkerResponseSource
      CacheStorage # cache-storage
      HttpCache    # http-cache
      FallbackCode # fallback-code
      Network      # network
    end

    # Determines what type of Trust Token operation is executed and
    # depending on the type, some additional parameters. The values
    # are specified in third_party/blink/renderer/core/fetch/trust_token.idl.
    struct TrustTokenParams
      include JSON::Serializable
      getter type : TrustTokenOperationType
      @[JSON::Field(key: "refreshPolicy")]
      # Only set for "token-redemption" type and determine whether
      # to request a fresh SRR or use a still valid cached SRR.
      getter refresh_policy : String
      # Origins of issuers from whom to request tokens or redemption
      # records.
      getter issuers : Array(String)?
    end

    enum TrustTokenOperationType
      Issuance   # Issuance
      Redemption # Redemption
      Signing    # Signing
    end

    # The reason why Chrome uses a specific transport protocol for HTTP semantics.
    enum AlternateProtocolUsage
      AlternativeJobWonWithoutRace # alternativeJobWonWithoutRace
      AlternativeJobWonRace        # alternativeJobWonRace
      MainJobWonRace               # mainJobWonRace
      MappingMissing               # mappingMissing
      Broken                       # broken
      DnsAlpnH3JobWonWithoutRace   # dnsAlpnH3JobWonWithoutRace
      DnsAlpnH3JobWonRace          # dnsAlpnH3JobWonRace
      UnspecifiedReason            # unspecifiedReason
    end

    # HTTP response data.
    struct Response
      include JSON::Serializable
      # Response URL. This URL can be different from CachedResource.url in case of redirect.
      getter url : String
      # HTTP response status code.
      getter status : Int::Primitive
      @[JSON::Field(key: "statusText")]
      # HTTP response status text.
      getter status_text : String
      # HTTP response headers.
      getter headers : Headers
      @[JSON::Field(key: "headersText")]
      # HTTP response headers text. This has been replaced by the headers in Network.responseReceivedExtraInfo.
      getter headers_text : String?
      @[JSON::Field(key: "mimeType")]
      # Resource mimeType as determined by the browser.
      getter mime_type : String
      @[JSON::Field(key: "requestHeaders")]
      # Refined HTTP request headers that were actually transmitted over the network.
      getter request_headers : Headers?
      @[JSON::Field(key: "requestHeadersText")]
      # HTTP request headers text. This has been replaced by the headers in Network.requestWillBeSentExtraInfo.
      getter request_headers_text : String?
      @[JSON::Field(key: "connectionReused")]
      # Specifies whether physical connection was actually reused for this request.
      getter connection_reused : Bool
      @[JSON::Field(key: "connectionId")]
      # Physical connection id that was actually used for this request.
      getter connection_id : Number::Primitive
      @[JSON::Field(key: "remoteIPAddress")]
      # Remote IP address.
      getter remote_ip_address : String?
      @[JSON::Field(key: "remotePort")]
      # Remote port.
      getter remote_port : Int::Primitive?
      @[JSON::Field(key: "fromDiskCache")]
      # Specifies that the request was served from the disk cache.
      getter from_disk_cache : Bool?
      @[JSON::Field(key: "fromServiceWorker")]
      # Specifies that the request was served from the ServiceWorker.
      getter from_service_worker : Bool?
      @[JSON::Field(key: "fromPrefetchCache")]
      # Specifies that the request was served from the prefetch cache.
      getter from_prefetch_cache : Bool?
      @[JSON::Field(key: "encodedDataLength")]
      # Total number of bytes received for this request so far.
      getter encoded_data_length : Number::Primitive
      # Timing information for the given request.
      getter timing : ResourceTiming?
      @[JSON::Field(key: "serviceWorkerResponseSource")]
      # Response source of response from ServiceWorker.
      getter service_worker_response_source : ServiceWorkerResponseSource?
      @[JSON::Field(key: "responseTime")]
      # The time at which the returned response was generated.
      getter response_time : TimeSinceEpoch?
      @[JSON::Field(key: "cacheStorageCacheName")]
      # Cache Storage Cache Name.
      getter cache_storage_cache_name : String?
      # Protocol used to fetch this request.
      getter protocol : String?
      @[JSON::Field(key: "alternateProtocolUsage")]
      # The reason why Chrome uses a specific transport protocol for HTTP semantics.
      getter alternate_protocol_usage : AlternateProtocolUsage?
      @[JSON::Field(key: "securityState")]
      # Security state of the request resource.
      getter security_state : Security::SecurityState
      @[JSON::Field(key: "securityDetails")]
      # Security details for the request.
      getter security_details : SecurityDetails?
    end

    # WebSocket request data.
    struct WebSocketRequest
      include JSON::Serializable
      # HTTP request headers.
      getter headers : Headers
    end

    # WebSocket response data.
    struct WebSocketResponse
      include JSON::Serializable
      # HTTP response status code.
      getter status : Int::Primitive
      @[JSON::Field(key: "statusText")]
      # HTTP response status text.
      getter status_text : String
      # HTTP response headers.
      getter headers : Headers
      @[JSON::Field(key: "headersText")]
      # HTTP response headers text.
      getter headers_text : String?
      @[JSON::Field(key: "requestHeaders")]
      # HTTP request headers.
      getter request_headers : Headers?
      @[JSON::Field(key: "requestHeadersText")]
      # HTTP request headers text.
      getter request_headers_text : String?
    end

    # WebSocket message data. This represents an entire WebSocket message, not just a fragmented frame as the name suggests.
    struct WebSocketFrame
      include JSON::Serializable
      # WebSocket message opcode.
      getter opcode : Number::Primitive
      # WebSocket message mask.
      getter mask : Bool
      @[JSON::Field(key: "payloadData")]
      # WebSocket message payload data.
      # If the opcode is 1, this is a text message and payloadData is a UTF-8 string.
      # If the opcode isn't 1, then payloadData is a base64 encoded string representing binary data.
      getter payload_data : String
    end

    # Information about the cached resource.
    struct CachedResource
      include JSON::Serializable
      # Resource URL. This is the url of the original network request.
      getter url : String
      # Type of this resource.
      getter type : ResourceType
      # Cached response data.
      getter response : Response?
      @[JSON::Field(key: "bodySize")]
      # Cached response body size.
      getter body_size : Number::Primitive
    end

    # Information about the request initiator.
    struct Initiator
      include JSON::Serializable
      # Type of this initiator.
      getter type : String
      # Initiator JavaScript stack trace, set for Script only.
      getter stack : Runtime::StackTrace?
      # Initiator URL, set for Parser type or for Script type (when script is importing module) or for SignedExchange type.
      getter url : String?
      @[JSON::Field(key: "lineNumber")]
      # Initiator line number, set for Parser type or for Script type (when script is importing
      # module) (0-based).
      getter line_number : Number::Primitive?
      @[JSON::Field(key: "columnNumber")]
      # Initiator column number, set for Parser type or for Script type (when script is importing
      # module) (0-based).
      getter column_number : Number::Primitive?
      @[JSON::Field(key: "requestId")]
      # Set if another request triggered this request (e.g. preflight).
      getter request_id : RequestId?
    end

    # Cookie object
    struct Cookie
      include JSON::Serializable
      # Cookie name.
      getter name : String
      # Cookie value.
      getter value : String
      # Cookie domain.
      getter domain : String
      # Cookie path.
      getter path : String
      # Cookie expiration date as the number of seconds since the UNIX epoch.
      getter expires : Number::Primitive
      # Cookie size.
      getter size : Int::Primitive
      @[JSON::Field(key: "httpOnly")]
      # True if cookie is http-only.
      getter http_only : Bool
      # True if cookie is secure.
      getter secure : Bool
      # True in case of session cookie.
      getter session : Bool
      @[JSON::Field(key: "sameSite")]
      # Cookie SameSite type.
      getter same_site : CookieSameSite?
      # Cookie Priority
      getter priority : CookiePriority
      @[JSON::Field(key: "sameParty")]
      # True if cookie is SameParty.
      getter same_party : Bool
      @[JSON::Field(key: "sourceScheme")]
      # Cookie source scheme type.
      getter source_scheme : CookieSourceScheme
      @[JSON::Field(key: "sourcePort")]
      # Cookie source port. Valid values are {-1, [1, 65535]}, -1 indicates an unspecified port.
      # An unspecified port value allows protocol clients to emulate legacy cookie scope for the port.
      # This is a temporary ability and it will be removed in the future.
      getter source_port : Int::Primitive
      @[JSON::Field(key: "partitionKey")]
      # Cookie partition key. The site of the top-level URL the browser was visiting at the start
      # of the request to the endpoint that set the cookie.
      getter partition_key : String?
      @[JSON::Field(key: "partitionKeyOpaque")]
      # True if cookie partition key is opaque.
      getter partition_key_opaque : Bool?
    end

    # Types of reasons why a cookie may not be stored from a response.
    enum SetCookieBlockedReason
      SecureOnly                               # SecureOnly
      SameSiteStrict                           # SameSiteStrict
      SameSiteLax                              # SameSiteLax
      SameSiteUnspecifiedTreatedAsLax          # SameSiteUnspecifiedTreatedAsLax
      SameSiteNoneInsecure                     # SameSiteNoneInsecure
      UserPreferences                          # UserPreferences
      SyntaxError                              # SyntaxError
      SchemeNotSupported                       # SchemeNotSupported
      OverwriteSecure                          # OverwriteSecure
      InvalidDomain                            # InvalidDomain
      InvalidPrefix                            # InvalidPrefix
      UnknownError                             # UnknownError
      SchemefulSameSiteStrict                  # SchemefulSameSiteStrict
      SchemefulSameSiteLax                     # SchemefulSameSiteLax
      SchemefulSameSiteUnspecifiedTreatedAsLax # SchemefulSameSiteUnspecifiedTreatedAsLax
      SamePartyFromCrossPartyContext           # SamePartyFromCrossPartyContext
      SamePartyConflictsWithOtherAttributes    # SamePartyConflictsWithOtherAttributes
      NameValuePairExceedsMaxSize              # NameValuePairExceedsMaxSize
    end

    # Types of reasons why a cookie may not be sent with a request.
    enum CookieBlockedReason
      SecureOnly                               # SecureOnly
      NotOnPath                                # NotOnPath
      DomainMismatch                           # DomainMismatch
      SameSiteStrict                           # SameSiteStrict
      SameSiteLax                              # SameSiteLax
      SameSiteUnspecifiedTreatedAsLax          # SameSiteUnspecifiedTreatedAsLax
      SameSiteNoneInsecure                     # SameSiteNoneInsecure
      UserPreferences                          # UserPreferences
      UnknownError                             # UnknownError
      SchemefulSameSiteStrict                  # SchemefulSameSiteStrict
      SchemefulSameSiteLax                     # SchemefulSameSiteLax
      SchemefulSameSiteUnspecifiedTreatedAsLax # SchemefulSameSiteUnspecifiedTreatedAsLax
      SamePartyFromCrossPartyContext           # SamePartyFromCrossPartyContext
      NameValuePairExceedsMaxSize              # NameValuePairExceedsMaxSize
    end

    # A cookie which was not stored from a response with the corresponding reason.
    struct BlockedSetCookieWithReason
      include JSON::Serializable
      @[JSON::Field(key: "blockedReasons")]
      # The reason(s) this cookie was blocked.
      getter blocked_reasons : Array(SetCookieBlockedReason)
      @[JSON::Field(key: "cookieLine")]
      # The string representing this individual cookie as it would appear in the header.
      # This is not the entire "cookie" or "set-cookie" header which could have multiple cookies.
      getter cookie_line : String
      # The cookie object which represents the cookie which was not stored. It is optional because
      # sometimes complete cookie information is not available, such as in the case of parsing
      # errors.
      getter cookie : Cookie?
    end

    # A cookie with was not sent with a request with the corresponding reason.
    struct BlockedCookieWithReason
      include JSON::Serializable
      @[JSON::Field(key: "blockedReasons")]
      # The reason(s) the cookie was blocked.
      getter blocked_reasons : Array(CookieBlockedReason)
      # The cookie object representing the cookie which was not sent.
      getter cookie : Cookie
    end

    # Cookie parameter object
    struct CookieParam
      include JSON::Serializable
      # Cookie name.
      getter name : String
      # Cookie value.
      getter value : String
      # The request-URI to associate with the setting of the cookie. This value can affect the
      # default domain, path, source port, and source scheme values of the created cookie.
      getter url : String?
      # Cookie domain.
      getter domain : String?
      # Cookie path.
      getter path : String?
      # True if cookie is secure.
      getter secure : Bool?
      @[JSON::Field(key: "httpOnly")]
      # True if cookie is http-only.
      getter http_only : Bool?
      @[JSON::Field(key: "sameSite")]
      # Cookie SameSite type.
      getter same_site : CookieSameSite?
      # Cookie expiration date, session cookie if not set
      getter expires : TimeSinceEpoch?
      # Cookie Priority.
      getter priority : CookiePriority?
      @[JSON::Field(key: "sameParty")]
      # True if cookie is SameParty.
      getter same_party : Bool?
      @[JSON::Field(key: "sourceScheme")]
      # Cookie source scheme type.
      getter source_scheme : CookieSourceScheme?
      @[JSON::Field(key: "sourcePort")]
      # Cookie source port. Valid values are {-1, [1, 65535]}, -1 indicates an unspecified port.
      # An unspecified port value allows protocol clients to emulate legacy cookie scope for the port.
      # This is a temporary ability and it will be removed in the future.
      getter source_port : Int::Primitive?
      @[JSON::Field(key: "partitionKey")]
      # Cookie partition key. The site of the top-level URL the browser was visiting at the start
      # of the request to the endpoint that set the cookie.
      # If not set, the cookie will be set as not partitioned.
      getter partition_key : String?
    end

    # Authorization challenge for HTTP status code 401 or 407.
    struct AuthChallenge
      include JSON::Serializable
      # Source of the authentication challenge.
      getter source : String?
      # Origin of the challenger.
      getter origin : String
      # The authentication scheme used, such as basic or digest
      getter scheme : String
      # The realm of the challenge. May be empty.
      getter realm : String
    end

    # Response to an AuthChallenge.
    struct AuthChallengeResponse
      include JSON::Serializable
      # The decision on what to do in response to the authorization challenge.  Default means
      # deferring to the default behavior of the net stack, which will likely either the Cancel
      # authentication or display a popup dialog box.
      getter response : String
      # The username to provide, possibly empty. Should only be set if response is
      # ProvideCredentials.
      getter username : String?
      # The password to provide, possibly empty. Should only be set if response is
      # ProvideCredentials.
      getter password : String?
    end

    # Stages of the interception to begin intercepting. Request will intercept before the request is
    # sent. Response will intercept after the response is received.
    enum InterceptionStage
      Request         # Request
      HeadersReceived # HeadersReceived
    end

    # Request pattern for interception.
    struct RequestPattern
      include JSON::Serializable
      @[JSON::Field(key: "urlPattern")]
      # Wildcards (`'*'` -> zero or more, `'?'` -> exactly one) are allowed. Escape character is
      # backslash. Omitting is equivalent to `"*"`.
      getter url_pattern : String?
      @[JSON::Field(key: "resourceType")]
      # If set, only requests for matching resource types will be intercepted.
      getter resource_type : ResourceType?
      @[JSON::Field(key: "interceptionStage")]
      # Stage at which to begin intercepting requests. Default is Request.
      getter interception_stage : InterceptionStage?
    end

    # Information about a signed exchange signature.
    # https://wicg.github.io/webpackage/draft-yasskin-httpbis-origin-signed-exchanges-impl.html#rfc.section.3.1
    struct SignedExchangeSignature
      include JSON::Serializable
      # Signed exchange signature label.
      getter label : String
      # The hex string of signed exchange signature.
      getter signature : String
      # Signed exchange signature integrity.
      getter integrity : String
      @[JSON::Field(key: "certUrl")]
      # Signed exchange signature cert Url.
      getter cert_url : String?
      @[JSON::Field(key: "certSha256")]
      # The hex string of signed exchange signature cert sha256.
      getter cert_sha256 : String?
      @[JSON::Field(key: "validityUrl")]
      # Signed exchange signature validity Url.
      getter validity_url : String
      # Signed exchange signature date.
      getter date : Int::Primitive
      # Signed exchange signature expires.
      getter expires : Int::Primitive
      # The encoded certificates.
      getter certificates : Array(String)?
    end

    # Information about a signed exchange header.
    # https://wicg.github.io/webpackage/draft-yasskin-httpbis-origin-signed-exchanges-impl.html#cbor-representation
    struct SignedExchangeHeader
      include JSON::Serializable
      @[JSON::Field(key: "requestUrl")]
      # Signed exchange request URL.
      getter request_url : String
      @[JSON::Field(key: "responseCode")]
      # Signed exchange response code.
      getter response_code : Int::Primitive
      @[JSON::Field(key: "responseHeaders")]
      # Signed exchange response headers.
      getter response_headers : Headers
      # Signed exchange response signature.
      getter signatures : Array(SignedExchangeSignature)
      @[JSON::Field(key: "headerIntegrity")]
      # Signed exchange header integrity hash in the form of "sha256-<base64-hash-value>".
      getter header_integrity : String
    end

    # Field type for a signed exchange related error.
    enum SignedExchangeErrorField
      SignatureSig         # signatureSig
      SignatureIntegrity   # signatureIntegrity
      SignatureCertUrl     # signatureCertUrl
      SignatureCertSha256  # signatureCertSha256
      SignatureValidityUrl # signatureValidityUrl
      SignatureTimestamps  # signatureTimestamps
    end

    # Information about a signed exchange response.
    struct SignedExchangeError
      include JSON::Serializable
      # Error message.
      getter message : String
      @[JSON::Field(key: "signatureIndex")]
      # The index of the signature which caused the error.
      getter signature_index : Int::Primitive?
      @[JSON::Field(key: "errorField")]
      # The field which caused the error.
      getter error_field : SignedExchangeErrorField?
    end

    # Information about a signed exchange response.
    struct SignedExchangeInfo
      include JSON::Serializable
      @[JSON::Field(key: "outerResponse")]
      # The outer response of signed HTTP exchange which was received from network.
      getter outer_response : Response
      # Information about the signed exchange header.
      getter header : SignedExchangeHeader?
      @[JSON::Field(key: "securityDetails")]
      # Security details for the signed exchange header.
      getter security_details : SecurityDetails?
      # Errors occurred while handling the signed exchagne.
      getter errors : Array(SignedExchangeError)?
    end

    # List of content encodings supported by the backend.
    enum ContentEncoding
      Deflate # deflate
      Gzip    # gzip
      Br      # br
    end

    enum PrivateNetworkRequestPolicy
      Allow                          # Allow
      BlockFromInsecureToMorePrivate # BlockFromInsecureToMorePrivate
      WarnFromInsecureToMorePrivate  # WarnFromInsecureToMorePrivate
      PreflightBlock                 # PreflightBlock
      PreflightWarn                  # PreflightWarn
    end

    enum IPAddressSpace
      Local   # Local
      Private # Private
      Public  # Public
      Unknown # Unknown
    end

    struct ConnectTiming
      include JSON::Serializable
      @[JSON::Field(key: "requestTime")]
      # Timing's requestTime is a baseline in seconds, while the other numbers are ticks in
      # milliseconds relatively to this requestTime. Matches ResourceTiming's requestTime for
      # the same request (but not for redirected requests).
      getter request_time : Number::Primitive
    end

    struct ClientSecurityState
      include JSON::Serializable
      @[JSON::Field(key: "initiatorIsSecureContext")]
      getter initiator_is_secure_context : Bool
      @[JSON::Field(key: "initiatorIPAddressSpace")]
      getter initiator_ip_address_space : IPAddressSpace
      @[JSON::Field(key: "privateNetworkRequestPolicy")]
      getter private_network_request_policy : PrivateNetworkRequestPolicy
    end

    enum CrossOriginOpenerPolicyValue
      SameOrigin                 # SameOrigin
      SameOriginAllowPopups      # SameOriginAllowPopups
      RestrictProperties         # RestrictProperties
      UnsafeNone                 # UnsafeNone
      SameOriginPlusCoep         # SameOriginPlusCoep
      RestrictPropertiesPlusCoep # RestrictPropertiesPlusCoep
    end

    struct CrossOriginOpenerPolicyStatus
      include JSON::Serializable
      getter value : CrossOriginOpenerPolicyValue
      @[JSON::Field(key: "reportOnlyValue")]
      getter report_only_value : CrossOriginOpenerPolicyValue
      @[JSON::Field(key: "reportingEndpoint")]
      getter reporting_endpoint : String?
      @[JSON::Field(key: "reportOnlyReportingEndpoint")]
      getter report_only_reporting_endpoint : String?
    end

    enum CrossOriginEmbedderPolicyValue
      None           # None
      Credentialless # Credentialless
      RequireCorp    # RequireCorp
    end

    struct CrossOriginEmbedderPolicyStatus
      include JSON::Serializable
      getter value : CrossOriginEmbedderPolicyValue
      @[JSON::Field(key: "reportOnlyValue")]
      getter report_only_value : CrossOriginEmbedderPolicyValue
      @[JSON::Field(key: "reportingEndpoint")]
      getter reporting_endpoint : String?
      @[JSON::Field(key: "reportOnlyReportingEndpoint")]
      getter report_only_reporting_endpoint : String?
    end

    struct SecurityIsolationStatus
      include JSON::Serializable
      getter coop : CrossOriginOpenerPolicyStatus?
      getter coep : CrossOriginEmbedderPolicyStatus?
    end

    # The status of a Reporting API report.
    enum ReportStatus
      Queued           # Queued
      Pending          # Pending
      MarkedForRemoval # MarkedForRemoval
      Success          # Success
    end

    alias ReportId = String

    # An object representing a report generated by the Reporting API.
    struct ReportingApiReport
      include JSON::Serializable
      getter id : ReportId
      @[JSON::Field(key: "initiatorUrl")]
      # The URL of the document that triggered the report.
      getter initiator_url : String
      # The name of the endpoint group that should be used to deliver the report.
      getter destination : String
      # The type of the report (specifies the set of data that is contained in the report body).
      getter type : String
      # When the report was generated.
      getter timestamp : Network::TimeSinceEpoch
      # How many uploads deep the related request was.
      getter depth : Int::Primitive
      @[JSON::Field(key: "completedAttempts")]
      # The number of delivery attempts made so far, not including an active attempt.
      getter completed_attempts : Int::Primitive
      getter body : JSON::Any
      getter status : ReportStatus
    end

    struct ReportingApiEndpoint
      include JSON::Serializable
      # The URL of the endpoint to which reports may be delivered.
      getter url : String
      @[JSON::Field(key: "groupName")]
      # Name of the endpoint group.
      getter group_name : String
    end

    # An object providing the result of a network resource load.
    struct LoadNetworkResourcePageResult
      include JSON::Serializable
      getter success : Bool
      @[JSON::Field(key: "netError")]
      # Optional values used for error reporting.
      getter net_error : Number::Primitive?
      @[JSON::Field(key: "netErrorName")]
      getter net_error_name : String?
      @[JSON::Field(key: "httpStatusCode")]
      getter http_status_code : Number::Primitive?
      # If successful, one of the following two fields holds the result.
      getter stream : IO::StreamHandle?
      # Response headers.
      getter headers : Network::Headers?
    end

    # An options object that may be extended later to better support CORS,
    # CORB and streaming.
    struct LoadNetworkResourceOptions
      include JSON::Serializable
      @[JSON::Field(key: "disableCache")]
      getter disable_cache : Bool
      @[JSON::Field(key: "includeCredentials")]
      getter include_credentials : Bool
    end

    # ----------------------------------------
    # Network Section: commands
    # ----------------------------------------

    # Sets a list of content encodings that will be accepted. Empty list means no encoding is accepted.
    struct SetAcceptedEncodings
      include Protocol::Command
      include JSON::Serializable
    end

    # Clears accepted encodings set by setAcceptedEncodings
    struct ClearAcceptedEncodingsOverride
      include Protocol::Command
      include JSON::Serializable
    end

    # Tells whether clearing browser cache is supported.
    struct CanClearBrowserCache
      include Protocol::Command
      include JSON::Serializable
      # True if browser cache can be cleared.
      getter result : Bool
    end

    # Tells whether clearing browser cookies is supported.
    struct CanClearBrowserCookies
      include Protocol::Command
      include JSON::Serializable
      # True if browser cookies can be cleared.
      getter result : Bool
    end

    # Tells whether emulation of network conditions is supported.
    struct CanEmulateNetworkConditions
      include Protocol::Command
      include JSON::Serializable
      # True if emulation of network conditions is supported.
      getter result : Bool
    end

    # Clears browser cache.
    struct ClearBrowserCache
      include Protocol::Command
      include JSON::Serializable
    end

    # Clears browser cookies.
    struct ClearBrowserCookies
      include Protocol::Command
      include JSON::Serializable
    end

    # Response to Network.requestIntercepted which either modifies the request to continue with any
    # modifications, or blocks it, or completes it with the provided response bytes. If a network
    # fetch occurs as a result which encounters a redirect an additional Network.requestIntercepted
    # event will be sent with the same InterceptionId.
    # Deprecated, use Fetch.continueRequest, Fetch.fulfillRequest and Fetch.failRequest instead.
    struct ContinueInterceptedRequest
      include Protocol::Command
      include JSON::Serializable
    end

    # Deletes browser cookies with matching name and url or domain/path pair.
    struct DeleteCookies
      include Protocol::Command
      include JSON::Serializable
    end

    # Disables network tracking, prevents network events from being sent to the client.
    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    # Activates emulation of network conditions.
    struct EmulateNetworkConditions
      include Protocol::Command
      include JSON::Serializable
    end

    # Enables network tracking, network events will now be delivered to the client.
    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    # Returns all browser cookies. Depending on the backend support, will return detailed cookie
    # information in the `cookies` field.
    struct GetAllCookies
      include Protocol::Command
      include JSON::Serializable
      # Array of cookie objects.
      getter cookies : Array(Cookie)
    end

    # Returns the DER-encoded certificate.
    struct GetCertificate
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "tableNames")]
      getter table_names : Array(String)
    end

    # Returns all browser cookies for the current URL. Depending on the backend support, will return
    # detailed cookie information in the `cookies` field.
    struct GetCookies
      include Protocol::Command
      include JSON::Serializable
      # Array of cookie objects.
      getter cookies : Array(Cookie)
    end

    # Returns content served for the given request.
    struct GetResponseBody
      include Protocol::Command
      include JSON::Serializable
      # Response body.
      getter body : String
      @[JSON::Field(key: "base64Encoded")]
      # True, if content was sent as base64.
      getter base64_encoded : Bool
    end

    # Returns post data sent with the request. Returns an error when no data was sent with the request.
    struct GetRequestPostData
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "postData")]
      # Request body string, omitting files from multipart requests
      getter post_data : String
    end

    # Returns content served for the given currently intercepted request.
    struct GetResponseBodyForInterception
      include Protocol::Command
      include JSON::Serializable
      # Response body.
      getter body : String
      @[JSON::Field(key: "base64Encoded")]
      # True, if content was sent as base64.
      getter base64_encoded : Bool
    end

    # Returns a handle to the stream representing the response body. Note that after this command,
    # the intercepted request can't be continued as is -- you either need to cancel it or to provide
    # the response body. The stream only supports sequential read, IO.read will fail if the position
    # is specified.
    struct TakeResponseBodyForInterceptionAsStream
      include Protocol::Command
      include JSON::Serializable
      getter stream : IO::StreamHandle
    end

    # This method sends a new XMLHttpRequest which is identical to the original one. The following
    # parameters should be identical: method, url, async, request body, extra headers, withCredentials
    # attribute, user, password.
    struct ReplayXHR
      include Protocol::Command
      include JSON::Serializable
    end

    # Searches for given string in response content.
    struct SearchInResponseBody
      include Protocol::Command
      include JSON::Serializable
      # List of search matches.
      getter result : Array(Debugger::SearchMatch)
    end

    # Blocks URLs from loading.
    struct SetBlockedURLs
      include Protocol::Command
      include JSON::Serializable
    end

    # Toggles ignoring of service worker for each request.
    struct SetBypassServiceWorker
      include Protocol::Command
      include JSON::Serializable
    end

    # Toggles ignoring cache for each request. If `true`, cache will not be used.
    struct SetCacheDisabled
      include Protocol::Command
      include JSON::Serializable
    end

    # Sets a cookie with the given cookie data; may overwrite equivalent cookies if they exist.
    struct SetCookie
      include Protocol::Command
      include JSON::Serializable
      # Always set to true. If an error occurs, the response indicates protocol error.
      getter success : Bool
    end

    # Sets given cookies.
    struct SetCookies
      include Protocol::Command
      include JSON::Serializable
    end

    # Specifies whether to always send extra HTTP headers with the requests from this page.
    struct SetExtraHTTPHeaders
      include Protocol::Command
      include JSON::Serializable
    end

    # Specifies whether to attach a page script stack id in requests
    struct SetAttachDebugStack
      include Protocol::Command
      include JSON::Serializable
    end

    # Sets the requests to intercept that match the provided patterns and optionally resource types.
    # Deprecated, please use Fetch.enable instead.
    struct SetRequestInterception
      include Protocol::Command
      include JSON::Serializable
    end

    # Allows overriding user agent with the given string.
    struct SetUserAgentOverride
      include Protocol::Command
      include JSON::Serializable
    end

    # Returns information about the COEP/COOP isolation status.
    struct GetSecurityIsolationStatus
      include Protocol::Command
      include JSON::Serializable
      getter status : SecurityIsolationStatus
    end

    # Enables tracking for the Reporting API, events generated by the Reporting API will now be delivered to the client.
    # Enabling triggers 'reportingApiReportAdded' for all existing reports.
    struct EnableReportingApi
      include Protocol::Command
      include JSON::Serializable
    end

    # Fetches the resource and returns the content.
    struct LoadNetworkResource
      include Protocol::Command
      include JSON::Serializable
      getter resource : LoadNetworkResourcePageResult
    end

    # ----------------------------------------
    # Network Section: events
    # ----------------------------------------

    # Fired when data chunk was received over the network.
    struct DataReceived
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "requestId")]
      # Request identifier.
      getter request_id : RequestId
      # Timestamp.
      getter timestamp : MonotonicTime
      @[JSON::Field(key: "dataLength")]
      # Data chunk length.
      getter data_length : Int::Primitive
      @[JSON::Field(key: "encodedDataLength")]
      # Actual bytes received (might be less than dataLength for compressed encodings).
      getter encoded_data_length : Int::Primitive
    end

    # Fired when EventSource message is received.
    struct EventSourceMessageReceived
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "requestId")]
      # Request identifier.
      getter request_id : RequestId
      # Timestamp.
      getter timestamp : MonotonicTime
      @[JSON::Field(key: "eventName")]
      # Message type.
      getter event_name : String
      @[JSON::Field(key: "eventId")]
      # Message identifier.
      getter event_id : String
      # Message content.
      getter data : String
    end

    # Fired when HTTP request has failed to load.
    struct LoadingFailed
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "requestId")]
      # Request identifier.
      getter request_id : RequestId
      # Timestamp.
      getter timestamp : MonotonicTime
      # Resource type.
      getter type : ResourceType
      @[JSON::Field(key: "errorText")]
      # User friendly error message.
      getter error_text : String
      # True if loading was canceled.
      getter canceled : Bool?
      @[JSON::Field(key: "blockedReason")]
      # The reason why loading was blocked, if any.
      getter blocked_reason : BlockedReason?
      @[JSON::Field(key: "corsErrorStatus")]
      # The reason why loading was blocked by CORS, if any.
      getter cors_error_status : CorsErrorStatus?
    end

    # Fired when HTTP request has finished loading.
    struct LoadingFinished
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "requestId")]
      # Request identifier.
      getter request_id : RequestId
      # Timestamp.
      getter timestamp : MonotonicTime
      @[JSON::Field(key: "encodedDataLength")]
      # Total number of bytes received for this request.
      getter encoded_data_length : Number::Primitive
      @[JSON::Field(key: "shouldReportCorbBlocking")]
      # Set when 1) response was blocked by Cross-Origin Read Blocking and also
      # 2) this needs to be reported to the DevTools console.
      getter should_report_corb_blocking : Bool?
    end

    # Details of an intercepted HTTP request, which must be either allowed, blocked, modified or
    # mocked.
    # Deprecated, use Fetch.requestPaused instead.
    struct RequestIntercepted
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "interceptionId")]
      # Each request the page makes will have a unique id, however if any redirects are encountered
      # while processing that fetch, they will be reported with the same id as the original fetch.
      # Likewise if HTTP authentication is needed then the same fetch id will be used.
      getter interception_id : InterceptionId
      getter request : Request
      @[JSON::Field(key: "frameId")]
      # The id of the frame that initiated the request.
      getter frame_id : Page::FrameId
      @[JSON::Field(key: "resourceType")]
      # How the requested resource will be used.
      getter resource_type : ResourceType
      @[JSON::Field(key: "isNavigationRequest")]
      # Whether this is a navigation request, which can abort the navigation completely.
      getter is_navigation_request : Bool
      @[JSON::Field(key: "isDownload")]
      # Set if the request is a navigation that will result in a download.
      # Only present after response is received from the server (i.e. HeadersReceived stage).
      getter is_download : Bool?
      @[JSON::Field(key: "redirectUrl")]
      # Redirect location, only sent if a redirect was intercepted.
      getter redirect_url : String?
      @[JSON::Field(key: "authChallenge")]
      # Details of the Authorization Challenge encountered. If this is set then
      # continueInterceptedRequest must contain an authChallengeResponse.
      getter auth_challenge : AuthChallenge?
      @[JSON::Field(key: "responseErrorReason")]
      # Response error if intercepted at response stage or if redirect occurred while intercepting
      # request.
      getter response_error_reason : ErrorReason?
      @[JSON::Field(key: "responseStatusCode")]
      # Response code if intercepted at response stage or if redirect occurred while intercepting
      # request or auth retry occurred.
      getter response_status_code : Int::Primitive?
      @[JSON::Field(key: "responseHeaders")]
      # Response headers if intercepted at the response stage or if redirect occurred while
      # intercepting request or auth retry occurred.
      getter response_headers : Headers?
      @[JSON::Field(key: "requestId")]
      # If the intercepted request had a corresponding requestWillBeSent event fired for it, then
      # this requestId will be the same as the requestId present in the requestWillBeSent event.
      getter request_id : RequestId?
    end

    # Fired if request ended up loading from cache.
    struct RequestServedFromCache
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "requestId")]
      # Request identifier.
      getter request_id : RequestId
    end

    # Fired when page is about to send HTTP request.
    struct RequestWillBeSent
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "requestId")]
      # Request identifier.
      getter request_id : RequestId
      @[JSON::Field(key: "loaderId")]
      # Loader identifier. Empty string if the request is fetched from worker.
      getter loader_id : LoaderId
      @[JSON::Field(key: "documentURL")]
      # URL of the document this request is loaded for.
      getter document_url : String
      # Request data.
      getter request : Request
      # Timestamp.
      getter timestamp : MonotonicTime
      @[JSON::Field(key: "wallTime")]
      # Timestamp.
      getter wall_time : TimeSinceEpoch
      # Request initiator.
      getter initiator : Initiator
      @[JSON::Field(key: "redirectHasExtraInfo")]
      # In the case that redirectResponse is populated, this flag indicates whether
      # requestWillBeSentExtraInfo and responseReceivedExtraInfo events will be or were emitted
      # for the request which was just redirected.
      getter redirect_has_extra_info : Bool
      @[JSON::Field(key: "redirectResponse")]
      # Redirect response data.
      getter redirect_response : Response?
      # Type of this resource.
      getter type : ResourceType?
      @[JSON::Field(key: "frameId")]
      # Frame identifier.
      getter frame_id : Page::FrameId?
      @[JSON::Field(key: "hasUserGesture")]
      # Whether the request is initiated by a user gesture. Defaults to false.
      getter has_user_gesture : Bool?
    end

    # Fired when resource loading priority is changed
    struct ResourceChangedPriority
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "requestId")]
      # Request identifier.
      getter request_id : RequestId
      @[JSON::Field(key: "newPriority")]
      # New priority
      getter new_priority : ResourcePriority
      # Timestamp.
      getter timestamp : MonotonicTime
    end

    # Fired when a signed exchange was received over the network
    struct SignedExchangeReceived
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "requestId")]
      # Request identifier.
      getter request_id : RequestId
      # Information about the signed exchange response.
      getter info : SignedExchangeInfo
    end

    # Fired when HTTP response is available.
    struct ResponseReceived
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "requestId")]
      # Request identifier.
      getter request_id : RequestId
      @[JSON::Field(key: "loaderId")]
      # Loader identifier. Empty string if the request is fetched from worker.
      getter loader_id : LoaderId
      # Timestamp.
      getter timestamp : MonotonicTime
      # Resource type.
      getter type : ResourceType
      # Response data.
      getter response : Response
      @[JSON::Field(key: "hasExtraInfo")]
      # Indicates whether requestWillBeSentExtraInfo and responseReceivedExtraInfo events will be
      # or were emitted for this request.
      getter has_extra_info : Bool
      @[JSON::Field(key: "frameId")]
      # Frame identifier.
      getter frame_id : Page::FrameId?
    end

    # Fired when WebSocket is closed.
    struct WebSocketClosed
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "requestId")]
      # Request identifier.
      getter request_id : RequestId
      # Timestamp.
      getter timestamp : MonotonicTime
    end

    # Fired upon WebSocket creation.
    struct WebSocketCreated
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "requestId")]
      # Request identifier.
      getter request_id : RequestId
      # WebSocket request URL.
      getter url : String
      # Request initiator.
      getter initiator : Initiator?
    end

    # Fired when WebSocket message error occurs.
    struct WebSocketFrameError
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "requestId")]
      # Request identifier.
      getter request_id : RequestId
      # Timestamp.
      getter timestamp : MonotonicTime
      @[JSON::Field(key: "errorMessage")]
      # WebSocket error message.
      getter error_message : String
    end

    # Fired when WebSocket message is received.
    struct WebSocketFrameReceived
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "requestId")]
      # Request identifier.
      getter request_id : RequestId
      # Timestamp.
      getter timestamp : MonotonicTime
      # WebSocket response data.
      getter response : WebSocketFrame
    end

    # Fired when WebSocket message is sent.
    struct WebSocketFrameSent
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "requestId")]
      # Request identifier.
      getter request_id : RequestId
      # Timestamp.
      getter timestamp : MonotonicTime
      # WebSocket response data.
      getter response : WebSocketFrame
    end

    # Fired when WebSocket handshake response becomes available.
    struct WebSocketHandshakeResponseReceived
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "requestId")]
      # Request identifier.
      getter request_id : RequestId
      # Timestamp.
      getter timestamp : MonotonicTime
      # WebSocket response data.
      getter response : WebSocketResponse
    end

    # Fired when WebSocket is about to initiate handshake.
    struct WebSocketWillSendHandshakeRequest
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "requestId")]
      # Request identifier.
      getter request_id : RequestId
      # Timestamp.
      getter timestamp : MonotonicTime
      @[JSON::Field(key: "wallTime")]
      # UTC Timestamp.
      getter wall_time : TimeSinceEpoch
      # WebSocket request data.
      getter request : WebSocketRequest
    end

    # Fired upon WebTransport creation.
    struct WebTransportCreated
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "transportId")]
      # WebTransport identifier.
      getter transport_id : RequestId
      # WebTransport request URL.
      getter url : String
      # Timestamp.
      getter timestamp : MonotonicTime
      # Request initiator.
      getter initiator : Initiator?
    end

    # Fired when WebTransport handshake is finished.
    struct WebTransportConnectionEstablished
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "transportId")]
      # WebTransport identifier.
      getter transport_id : RequestId
      # Timestamp.
      getter timestamp : MonotonicTime
    end

    # Fired when WebTransport is disposed.
    struct WebTransportClosed
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "transportId")]
      # WebTransport identifier.
      getter transport_id : RequestId
      # Timestamp.
      getter timestamp : MonotonicTime
    end

    # Fired when additional information about a requestWillBeSent event is available from the
    # network stack. Not every requestWillBeSent event will have an additional
    # requestWillBeSentExtraInfo fired for it, and there is no guarantee whether requestWillBeSent
    # or requestWillBeSentExtraInfo will be fired first for the same request.
    struct RequestWillBeSentExtraInfo
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "requestId")]
      # Request identifier. Used to match this information to an existing requestWillBeSent event.
      getter request_id : RequestId
      @[JSON::Field(key: "associatedCookies")]
      # A list of cookies potentially associated to the requested URL. This includes both cookies sent with
      # the request and the ones not sent; the latter are distinguished by having blockedReason field set.
      getter associated_cookies : Array(BlockedCookieWithReason)
      # Raw request headers as they will be sent over the wire.
      getter headers : Headers
      @[JSON::Field(key: "connectTiming")]
      # Connection timing information for the request.
      getter connect_timing : ConnectTiming
      @[JSON::Field(key: "clientSecurityState")]
      # The client security state set for the request.
      getter client_security_state : ClientSecurityState?
    end

    # Fired when additional information about a responseReceived event is available from the network
    # stack. Not every responseReceived event will have an additional responseReceivedExtraInfo for
    # it, and responseReceivedExtraInfo may be fired before or after responseReceived.
    struct ResponseReceivedExtraInfo
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "requestId")]
      # Request identifier. Used to match this information to another responseReceived event.
      getter request_id : RequestId
      @[JSON::Field(key: "blockedCookies")]
      # A list of cookies which were not stored from the response along with the corresponding
      # reasons for blocking. The cookies here may not be valid due to syntax errors, which
      # are represented by the invalid cookie line string instead of a proper cookie.
      getter blocked_cookies : Array(BlockedSetCookieWithReason)
      # Raw response headers as they were received over the wire.
      getter headers : Headers
      @[JSON::Field(key: "resourceIPAddressSpace")]
      # The IP address space of the resource. The address space can only be determined once the transport
      # established the connection, so we can't send it in `requestWillBeSentExtraInfo`.
      getter resource_ip_address_space : IPAddressSpace
      @[JSON::Field(key: "statusCode")]
      # The status code of the response. This is useful in cases the request failed and no responseReceived
      # event is triggered, which is the case for, e.g., CORS errors. This is also the correct status code
      # for cached requests, where the status in responseReceived is a 200 and this will be 304.
      getter status_code : Int::Primitive
      @[JSON::Field(key: "headersText")]
      # Raw response header text as it was received over the wire. The raw text may not always be
      # available, such as in the case of HTTP/2 or QUIC.
      getter headers_text : String?
    end

    # Fired exactly once for each Trust Token operation. Depending on
    # the type of the operation and whether the operation succeeded or
    # failed, the event is fired before the corresponding request was sent
    # or after the response was received.
    struct TrustTokenOperationDone
      include JSON::Serializable
      include Protocol::Event
      # Detailed success or error status of the operation.
      # 'AlreadyExists' also signifies a successful operation, as the result
      # of the operation already exists und thus, the operation was abort
      # preemptively (e.g. a cache hit).
      getter status : String
      getter type : TrustTokenOperationType
      @[JSON::Field(key: "requestId")]
      getter request_id : RequestId
      @[JSON::Field(key: "topLevelOrigin")]
      # Top level origin. The context in which the operation was attempted.
      getter top_level_origin : String?
      @[JSON::Field(key: "issuerOrigin")]
      # Origin of the issuer in case of a "Issuance" or "Redemption" operation.
      getter issuer_origin : String?
      @[JSON::Field(key: "issuedTokenCount")]
      # The number of obtained Trust Tokens on a successful "Issuance" operation.
      getter issued_token_count : Int::Primitive?
    end

    # Fired once when parsing the .wbn file has succeeded.
    # The event contains the information about the web bundle contents.
    struct SubresourceWebBundleMetadataReceived
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "requestId")]
      # Request identifier. Used to match this information to another event.
      getter request_id : RequestId
      # A list of URLs of resources in the subresource Web Bundle.
      getter urls : Array(String)
    end

    # Fired once when parsing the .wbn file has failed.
    struct SubresourceWebBundleMetadataError
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "requestId")]
      # Request identifier. Used to match this information to another event.
      getter request_id : RequestId
      @[JSON::Field(key: "errorMessage")]
      # Error message
      getter error_message : String
    end

    # Fired when handling requests for resources within a .wbn file.
    # Note: this will only be fired for resources that are requested by the webpage.
    struct SubresourceWebBundleInnerResponseParsed
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "innerRequestId")]
      # Request identifier of the subresource request
      getter inner_request_id : RequestId
      @[JSON::Field(key: "innerRequestURL")]
      # URL of the subresource resource.
      getter inner_request_url : String
      @[JSON::Field(key: "bundleRequestId")]
      # Bundle request identifier. Used to match this information to another event.
      # This made be absent in case when the instrumentation was enabled only
      # after webbundle was parsed.
      getter bundle_request_id : RequestId?
    end

    # Fired when request for resources within a .wbn file failed.
    struct SubresourceWebBundleInnerResponseError
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "innerRequestId")]
      # Request identifier of the subresource request
      getter inner_request_id : RequestId
      @[JSON::Field(key: "innerRequestURL")]
      # URL of the subresource resource.
      getter inner_request_url : String
      @[JSON::Field(key: "errorMessage")]
      # Error message
      getter error_message : String
      @[JSON::Field(key: "bundleRequestId")]
      # Bundle request identifier. Used to match this information to another event.
      # This made be absent in case when the instrumentation was enabled only
      # after webbundle was parsed.
      getter bundle_request_id : RequestId?
    end

    # Is sent whenever a new report is added.
    # And after 'enableReportingApi' for all existing reports.
    struct ReportingApiReportAdded
      include JSON::Serializable
      include Protocol::Event
      getter report : ReportingApiReport
    end

    struct ReportingApiReportUpdated
      include JSON::Serializable
      include Protocol::Event
      getter report : ReportingApiReport
    end

    struct ReportingApiEndpointsChangedForOrigin
      include JSON::Serializable
      include Protocol::Event
      # Origin of the document(s) which configured the endpoints.
      getter origin : String
      getter endpoints : Array(ReportingApiEndpoint)
    end
  end
end
