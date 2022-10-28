# ==========================================================================
# This domain allows configuring virtual authenticators to test the WebAuthn
# API.
# ==========================================================================

# common Command module
require "./command"

module Protocol
  module WebAuthn
    # ----------------------------------------
    # WebAuthn Section: types
    # ----------------------------------------

    alias AuthenticatorId = String

    enum AuthenticatorProtocol
      U2f   # u2f
      Ctap2 # ctap2
    end

    enum Ctap2Version
      Ctap20 # ctap2_0
      Ctap21 # ctap2_1
    end

    enum AuthenticatorTransport
      Usb      # usb
      Nfc      # nfc
      Ble      # ble
      Cable    # cable
      Internal # internal
    end

    struct VirtualAuthenticatorOptions
      include JSON::Serializable
      getter protocol : AuthenticatorProtocol
      @[JSON::Field(key: "ctap2Version")]
      # Defaults to ctap2_0. Ignored if |protocol| == u2f.
      getter ctap2_version : Ctap2Version?
      getter transport : AuthenticatorTransport
      @[JSON::Field(key: "hasResidentKey")]
      # Defaults to false.
      getter has_resident_key : Bool?
      @[JSON::Field(key: "hasUserVerification")]
      # Defaults to false.
      getter has_user_verification : Bool?
      @[JSON::Field(key: "hasLargeBlob")]
      # If set to true, the authenticator will support the largeBlob extension.
      # https://w3c.github.io/webauthn#largeBlob
      # Defaults to false.
      getter has_large_blob : Bool?
      @[JSON::Field(key: "hasCredBlob")]
      # If set to true, the authenticator will support the credBlob extension.
      # https://fidoalliance.org/specs/fido-v2.1-rd-20201208/fido-client-to-authenticator-protocol-v2.1-rd-20201208.html#sctn-credBlob-extension
      # Defaults to false.
      getter has_cred_blob : Bool?
      @[JSON::Field(key: "hasMinPinLength")]
      # If set to true, the authenticator will support the minPinLength extension.
      # https://fidoalliance.org/specs/fido-v2.1-ps-20210615/fido-client-to-authenticator-protocol-v2.1-ps-20210615.html#sctn-minpinlength-extension
      # Defaults to false.
      getter has_min_pin_length : Bool?
      @[JSON::Field(key: "automaticPresenceSimulation")]
      # If set to true, tests of user presence will succeed immediately.
      # Otherwise, they will not be resolved. Defaults to true.
      getter automatic_presence_simulation : Bool?
      @[JSON::Field(key: "isUserVerified")]
      # Sets whether User Verification succeeds or fails for an authenticator.
      # Defaults to false.
      getter is_user_verified : Bool?
    end

    struct Credential
      include JSON::Serializable
      @[JSON::Field(key: "credentialId")]
      getter credential_id : String
      @[JSON::Field(key: "isResidentCredential")]
      getter is_resident_credential : Bool
      @[JSON::Field(key: "rpId")]
      # Relying Party ID the credential is scoped to. Must be set when adding a
      # credential.
      getter rp_id : String?
      @[JSON::Field(key: "privateKey")]
      # The ECDSA P-256 private key in PKCS#8 format. (Encoded as a base64 string when passed over JSON)
      getter private_key : String
      @[JSON::Field(key: "userHandle")]
      # An opaque byte sequence with a maximum size of 64 bytes mapping the
      # credential to a specific user. (Encoded as a base64 string when passed over JSON)
      getter user_handle : String?
      @[JSON::Field(key: "signCount")]
      # Signature counter. This is incremented by one for each successful
      # assertion.
      # See https://w3c.github.io/webauthn/#signature-counter
      getter sign_count : Int::Primitive
      @[JSON::Field(key: "largeBlob")]
      # The large blob associated with the credential.
      # See https://w3c.github.io/webauthn/#sctn-large-blob-extension (Encoded as a base64 string when passed over JSON)
      getter large_blob : String?
    end

    # ----------------------------------------
    # WebAuthn Section: commands
    # ----------------------------------------

    # Enable the WebAuthn domain and start intercepting credential storage and
    # retrieval with a virtual authenticator.
    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    # Disable the WebAuthn domain.
    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    # Creates and adds a virtual authenticator.
    struct AddVirtualAuthenticator
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "authenticatorId")]
      getter authenticator_id : AuthenticatorId
    end

    # Removes the given authenticator.
    struct RemoveVirtualAuthenticator
      include Protocol::Command
      include JSON::Serializable
    end

    # Adds the credential to the specified authenticator.
    struct AddCredential
      include Protocol::Command
      include JSON::Serializable
    end

    # Returns a single credential stored in the given virtual authenticator that
    # matches the credential ID.
    struct GetCredential
      include Protocol::Command
      include JSON::Serializable
      getter credential : Credential
    end

    # Returns all the credentials stored in the given virtual authenticator.
    struct GetCredentials
      include Protocol::Command
      include JSON::Serializable
      getter credentials : Array(Credential)
    end

    # Removes a credential from the authenticator.
    struct RemoveCredential
      include Protocol::Command
      include JSON::Serializable
    end

    # Clears all the credentials from the specified device.
    struct ClearCredentials
      include Protocol::Command
      include JSON::Serializable
    end

    # Sets whether User Verification succeeds or fails for an authenticator.
    # The default is true.
    struct SetUserVerified
      include Protocol::Command
      include JSON::Serializable
    end

    # Sets whether tests of user presence will succeed immediately (if true) or fail to resolve (if false) for an authenticator.
    # The default is true.
    struct SetAutomaticPresenceSimulation
      include Protocol::Command
      include JSON::Serializable
    end
  end
end
