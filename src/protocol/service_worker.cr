# ServiceWorker module dependencies
require "./target"

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module ServiceWorker
    # ----------------------------------------
    # ServiceWorker Section: types
    # ----------------------------------------

    alias RegistrationID = String

    # ServiceWorker registration.
    struct ServiceWorkerRegistration
      include JSON::Serializable
      @[JSON::Field(key: "registrationId")]
      getter registration_id : RegistrationID
      @[JSON::Field(key: "scopeURL")]
      getter scope_url : String
      @[JSON::Field(key: "isDeleted")]
      getter is_deleted : Bool
    end

    enum ServiceWorkerVersionRunningStatus
      Stopped  # stopped
      Starting # starting
      Running  # running
      Stopping # stopping
    end

    enum ServiceWorkerVersionStatus
      New        # new
      Installing # installing
      Installed  # installed
      Activating # activating
      Activated  # activated
      Redundant  # redundant
    end

    # ServiceWorker version.
    struct ServiceWorkerVersion
      include JSON::Serializable
      @[JSON::Field(key: "versionId")]
      getter version_id : String
      @[JSON::Field(key: "registrationId")]
      getter registration_id : RegistrationID
      @[JSON::Field(key: "scriptURL")]
      getter script_url : String
      @[JSON::Field(key: "runningStatus")]
      getter running_status : ServiceWorkerVersionRunningStatus
      getter status : ServiceWorkerVersionStatus
      @[JSON::Field(key: "scriptLastModified")]
      # The Last-Modified header value of the main script.
      getter script_last_modified : Number::Primitive?
      @[JSON::Field(key: "scriptResponseTime")]
      # The time at which the response headers of the main script were received from the server.
      # For cached script it is the last time the cache entry was validated.
      getter script_response_time : Number::Primitive?
      @[JSON::Field(key: "controlledClients")]
      getter controlled_clients : Array(Target::TargetID)?
      @[JSON::Field(key: "targetId")]
      getter target_id : Target::TargetID?
    end

    # ServiceWorker error message.
    struct ServiceWorkerErrorMessage
      include JSON::Serializable
      @[JSON::Field(key: "errorMessage")]
      getter error_message : String
      @[JSON::Field(key: "registrationId")]
      getter registration_id : RegistrationID
      @[JSON::Field(key: "versionId")]
      getter version_id : String
      @[JSON::Field(key: "sourceURL")]
      getter source_url : String
      @[JSON::Field(key: "lineNumber")]
      getter line_number : Int::Primitive
      @[JSON::Field(key: "columnNumber")]
      getter column_number : Int::Primitive
    end

    # ----------------------------------------
    # ServiceWorker Section: commands
    # ----------------------------------------

    struct DeliverPushMessage
      include Protocol::Command
      include JSON::Serializable
    end

    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    struct DispatchSyncEvent
      include Protocol::Command
      include JSON::Serializable
    end

    struct DispatchPeriodicSyncEvent
      include Protocol::Command
      include JSON::Serializable
    end

    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    struct InspectWorker
      include Protocol::Command
      include JSON::Serializable
    end

    struct SetForceUpdateOnPageLoad
      include Protocol::Command
      include JSON::Serializable
    end

    struct SkipWaiting
      include Protocol::Command
      include JSON::Serializable
    end

    struct StartWorker
      include Protocol::Command
      include JSON::Serializable
    end

    struct StopAllWorkers
      include Protocol::Command
      include JSON::Serializable
    end

    struct StopWorker
      include Protocol::Command
      include JSON::Serializable
    end

    struct Unregister
      include Protocol::Command
      include JSON::Serializable
    end

    struct UpdateRegistration
      include Protocol::Command
      include JSON::Serializable
    end

    # ----------------------------------------
    # ServiceWorker Section: events
    # ----------------------------------------

    struct WorkerErrorReported
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "errorMessage")]
      getter error_message : ServiceWorkerErrorMessage
    end

    struct WorkerRegistrationUpdated
      include JSON::Serializable
      include Protocol::Event
      getter registrations : Array(ServiceWorkerRegistration)
    end

    struct WorkerVersionUpdated
      include JSON::Serializable
      include Protocol::Event
      getter versions : Array(ServiceWorkerVersion)
    end
  end
end
