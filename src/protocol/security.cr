# ========
# Security
# ========

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module Security
    # ----------------------------------------
    # Security Section: types
    # ----------------------------------------

    # An internal certificate ID value.
    alias CertificateId = Int::Primitive

    # A description of mixed content (HTTP resources on HTTPS pages), as defined by
    # https://www.w3.org/TR/mixed-content/#categories
    @[DashEnum]
    enum MixedContentType
      Blockable           # blockable
      OptionallyBlockable # optionally-blockable
      None                # none
    end

    # The security level of a page or resource.
    @[DashEnum]
    enum SecurityState
      Unknown        # unknown
      Neutral        # neutral
      Insecure       # insecure
      Secure         # secure
      Info           # info
      InsecureBroken # insecure-broken
    end

    # Details about the security state of the page certificate.
    struct CertificateSecurityState
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
      # Page certificate.
      getter certificate : Array(String)
      @[JSON::Field(key: "subjectName")]
      # Certificate subject name.
      getter subject_name : String
      # Name of the issuing CA.
      getter issuer : String
      @[JSON::Field(key: "validFrom")]
      # Certificate valid from date.
      getter valid_from : Network::TimeSinceEpoch
      @[JSON::Field(key: "validTo")]
      # Certificate valid to (expiration) date
      getter valid_to : Network::TimeSinceEpoch
      @[JSON::Field(key: "certificateNetworkError")]
      # The highest priority network error code, if the certificate has an error.
      getter certificate_network_error : String?
      @[JSON::Field(key: "certificateHasWeakSignature")]
      # True if the certificate uses a weak signature aglorithm.
      getter certificate_has_weak_signature : Bool
      @[JSON::Field(key: "certificateHasSha1Signature")]
      # True if the certificate has a SHA1 signature in the chain.
      getter certificate_has_sha1_signature : Bool
      @[JSON::Field(key: "modernSSL")]
      # True if modern SSL
      getter modern_ssl : Bool
      @[JSON::Field(key: "obsoleteSslProtocol")]
      # True if the connection is using an obsolete SSL protocol.
      getter obsolete_ssl_protocol : Bool
      @[JSON::Field(key: "obsoleteSslKeyExchange")]
      # True if the connection is using an obsolete SSL key exchange.
      getter obsolete_ssl_key_exchange : Bool
      @[JSON::Field(key: "obsoleteSslCipher")]
      # True if the connection is using an obsolete SSL cipher.
      getter obsolete_ssl_cipher : Bool
      @[JSON::Field(key: "obsoleteSslSignature")]
      # True if the connection is using an obsolete SSL signature.
      getter obsolete_ssl_signature : Bool
    end

    enum SafetyTipStatus
      BadReputation # badReputation
      Lookalike     # lookalike
    end

    struct SafetyTipInfo
      include JSON::Serializable
      @[JSON::Field(key: "safetyTipStatus")]
      # Describes whether the page triggers any safety tips or reputation warnings. Default is unknown.
      getter safety_tip_status : SafetyTipStatus
      @[JSON::Field(key: "safeUrl")]
      # The URL the safety tip suggested ("Did you mean?"). Only filled in for lookalike matches.
      getter safe_url : String?
    end

    # Security state information about the page.
    struct VisibleSecurityState
      include JSON::Serializable
      @[JSON::Field(key: "securityState")]
      # The security level of the page.
      getter security_state : SecurityState
      @[JSON::Field(key: "certificateSecurityState")]
      # Security state details about the page certificate.
      getter certificate_security_state : CertificateSecurityState?
      @[JSON::Field(key: "safetyTipInfo")]
      # The type of Safety Tip triggered on the page. Note that this field will be set even if the Safety Tip UI was not actually shown.
      getter safety_tip_info : SafetyTipInfo?
      @[JSON::Field(key: "securityStateIssueIds")]
      # Array of security state issues ids.
      getter security_state_issue_ids : Array(String)
    end

    # An explanation of an factor contributing to the security state.
    struct SecurityStateExplanation
      include JSON::Serializable
      @[JSON::Field(key: "securityState")]
      # Security state representing the severity of the factor being explained.
      getter security_state : SecurityState
      # Title describing the type of factor.
      getter title : String
      # Short phrase describing the type of factor.
      getter summary : String
      # Full text explanation of the factor.
      getter description : String
      @[JSON::Field(key: "mixedContentType")]
      # The type of mixed content described by the explanation.
      getter mixed_content_type : MixedContentType
      # Page certificate.
      getter certificate : Array(String)
      # Recommendations to fix any issues.
      getter recommendations : Array(String)?
    end

    # Information about insecure content on the page.
    struct InsecureContentStatus
      include JSON::Serializable
      @[JSON::Field(key: "ranMixedContent")]
      # Always false.
      getter ran_mixed_content : Bool
      @[JSON::Field(key: "displayedMixedContent")]
      # Always false.
      getter displayed_mixed_content : Bool
      @[JSON::Field(key: "containedMixedForm")]
      # Always false.
      getter contained_mixed_form : Bool
      @[JSON::Field(key: "ranContentWithCertErrors")]
      # Always false.
      getter ran_content_with_cert_errors : Bool
      @[JSON::Field(key: "displayedContentWithCertErrors")]
      # Always false.
      getter displayed_content_with_cert_errors : Bool
      @[JSON::Field(key: "ranInsecureContentStyle")]
      # Always set to unknown.
      getter ran_insecure_content_style : SecurityState
      @[JSON::Field(key: "displayedInsecureContentStyle")]
      # Always set to unknown.
      getter displayed_insecure_content_style : SecurityState
    end

    # The action to take when a certificate error occurs. continue will continue processing the
    # request and cancel will cancel the request.
    enum CertificateErrorAction
      Continue # continue
      Cancel   # cancel
    end

    # ----------------------------------------
    # Security Section: commands
    # ----------------------------------------

    # Disables tracking security state changes.
    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    # Enables tracking security state changes.
    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    # Enable/disable whether all certificate errors should be ignored.
    struct SetIgnoreCertificateErrors
      include Protocol::Command
      include JSON::Serializable
    end

    # Handles a certificate error that fired a certificateError event.
    struct HandleCertificateError
      include Protocol::Command
      include JSON::Serializable
    end

    # Enable/disable overriding certificate errors. If enabled, all certificate error events need to
    # be handled by the DevTools client and should be answered with `handleCertificateError` commands.
    struct SetOverrideCertificateErrors
      include Protocol::Command
      include JSON::Serializable
    end

    # ----------------------------------------
    # Security Section: events
    # ----------------------------------------

    # There is a certificate error. If overriding certificate errors is enabled, then it should be
    # handled with the `handleCertificateError` command. Note: this event does not fire if the
    # certificate error has been allowed internally. Only one client per target should override
    # certificate errors at the same time.
    struct CertificateError
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "eventId")]
      # The ID of the event.
      getter event_id : Int::Primitive
      @[JSON::Field(key: "errorType")]
      # The type of the error.
      getter error_type : String
      @[JSON::Field(key: "requestURL")]
      # The url that was requested.
      getter request_url : String
    end

    # The security state of the page changed.
    struct VisibleSecurityStateChanged
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "visibleSecurityState")]
      # Security state information about the page.
      getter visible_security_state : VisibleSecurityState
    end

    # The security state of the page changed. No longer being sent.
    struct SecurityStateChanged
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "securityState")]
      # Security state.
      getter security_state : SecurityState
      @[JSON::Field(key: "schemeIsCryptographic")]
      # True if the page was loaded over cryptographic transport such as HTTPS.
      getter scheme_is_cryptographic : Bool
      # Previously a list of explanations for the security state. Now always
      # empty.
      getter explanations : Array(SecurityStateExplanation)
      @[JSON::Field(key: "insecureContentStatus")]
      # Information about insecure content on the page.
      getter insecure_content_status : InsecureContentStatus
      # Overrides user-visible description of the state. Always omitted.
      getter summary : String?
    end
  end
end
