# ================================================================================
# A domain for letting clients substitute browser's network layer with client code.
# ================================================================================

# Fetch module dependencies
require "./network"
require "./io"
require "./page"

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module Fetch
    # ----------------------------------------
    # Fetch Section: types
    # ----------------------------------------

    # Unique request identifier.
    alias RequestId = String

    # Stages of the request to handle. Request will intercept before the request is
    # sent. Response will intercept after the response is received (but before response
    # body is received).
    enum RequestStage
      Request  # Request
      Response # Response
    end

    struct RequestPattern
      include JSON::Serializable
      @[JSON::Field(key: "urlPattern")]
      # Wildcards (`'*'` -> zero or more, `'?'` -> exactly one) are allowed. Escape character is
      # backslash. Omitting is equivalent to `"*"`.
      getter url_pattern : String?
      @[JSON::Field(key: "resourceType")]
      # If set, only requests for matching resource types will be intercepted.
      getter resource_type : Network::ResourceType?
      @[JSON::Field(key: "requestStage")]
      # Stage at which to begin intercepting requests. Default is Request.
      getter request_stage : RequestStage?
    end

    # Response HTTP header entry
    struct HeaderEntry
      include JSON::Serializable
      getter name : String
      getter value : String
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

    # ----------------------------------------
    # Fetch Section: commands
    # ----------------------------------------

    # Disables the fetch domain.
    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    # Enables issuing of requestPaused events. A request will be paused until client
    # calls one of failRequest, fulfillRequest or continueRequest/continueWithAuth.
    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    # Causes the request to fail with specified reason.
    struct FailRequest
      include Protocol::Command
      include JSON::Serializable
    end

    # Provides response to the request.
    struct FulfillRequest
      include Protocol::Command
      include JSON::Serializable
    end

    # Continues the request, optionally modifying some of its parameters.
    struct ContinueRequest
      include Protocol::Command
      include JSON::Serializable
    end

    # Continues a request supplying authChallengeResponse following authRequired event.
    struct ContinueWithAuth
      include Protocol::Command
      include JSON::Serializable
    end

    # Continues loading of the paused response, optionally modifying the
    # response headers. If either responseCode or headers are modified, all of them
    # must be present.
    struct ContinueResponse
      include Protocol::Command
      include JSON::Serializable
    end

    # Causes the body of the response to be received from the server and
    # returned as a single string. May only be issued for a request that
    # is paused in the Response stage and is mutually exclusive with
    # takeResponseBodyForInterceptionAsStream. Calling other methods that
    # affect the request or disabling fetch domain before body is received
    # results in an undefined behavior.
    struct GetResponseBody
      include Protocol::Command
      include JSON::Serializable
      # Response body.
      getter body : String
      @[JSON::Field(key: "base64Encoded")]
      # True, if content was sent as base64.
      getter base64_encoded : Bool
    end

    # Returns a handle to the stream representing the response body.
    # The request must be paused in the HeadersReceived stage.
    # Note that after this command the request can't be continued
    # as is -- client either needs to cancel it or to provide the
    # response body.
    # The stream only supports sequential read, IO.read will fail if the position
    # is specified.
    # This method is mutually exclusive with getResponseBody.
    # Calling other methods that affect the request or disabling fetch
    # domain before body is received results in an undefined behavior.
    struct TakeResponseBodyAsStream
      include Protocol::Command
      include JSON::Serializable
      getter stream : IO::StreamHandle
    end

    # ----------------------------------------
    # Fetch Section: events
    # ----------------------------------------

    # Issued when the domain is enabled and the request URL matches the
    # specified filter. The request is paused until the client responds
    # with one of continueRequest, failRequest or fulfillRequest.
    # The stage of the request can be determined by presence of responseErrorReason
    # and responseStatusCode -- the request is at the response stage if either
    # of these fields is present and in the request stage otherwise.
    struct RequestPaused
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "requestId")]
      # Each request the page makes will have a unique id.
      getter request_id : RequestId
      # The details of the request.
      getter request : Network::Request
      @[JSON::Field(key: "frameId")]
      # The id of the frame that initiated the request.
      getter frame_id : Page::FrameId
      @[JSON::Field(key: "resourceType")]
      # How the requested resource will be used.
      getter resource_type : Network::ResourceType
      @[JSON::Field(key: "responseErrorReason")]
      # Response error if intercepted at response stage.
      getter response_error_reason : Network::ErrorReason?
      @[JSON::Field(key: "responseStatusCode")]
      # Response code if intercepted at response stage.
      getter response_status_code : Int::Primitive?
      @[JSON::Field(key: "responseStatusText")]
      # Response status text if intercepted at response stage.
      getter response_status_text : String?
      @[JSON::Field(key: "responseHeaders")]
      # Response headers if intercepted at the response stage.
      getter response_headers : Array(HeaderEntry)?
      @[JSON::Field(key: "networkId")]
      # If the intercepted request had a corresponding Network.requestWillBeSent event fired for it,
      # then this networkId will be the same as the requestId present in the requestWillBeSent event.
      getter network_id : Network::RequestId?
      @[JSON::Field(key: "redirectedRequestId")]
      # If the request is due to a redirect response from the server, the id of the request that
      # has caused the redirect.
      getter redirected_request_id : RequestId?
    end

    # Issued when the domain is enabled with handleAuthRequests set to true.
    # The request is paused until client responds with continueWithAuth.
    struct AuthRequired
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "requestId")]
      # Each request the page makes will have a unique id.
      getter request_id : RequestId
      # The details of the request.
      getter request : Network::Request
      @[JSON::Field(key: "frameId")]
      # The id of the frame that initiated the request.
      getter frame_id : Page::FrameId
      @[JSON::Field(key: "resourceType")]
      # How the requested resource will be used.
      getter resource_type : Network::ResourceType
      @[JSON::Field(key: "authChallenge")]
      # Details of the Authorization Challenge encountered.
      # If this is set, client should respond with continueRequest that
      # contains AuthChallengeResponse.
      getter auth_challenge : AuthChallenge
    end
  end
end
