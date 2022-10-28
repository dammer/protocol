# ====================================================
# Defines events for background web platform features.
# ====================================================

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module BackgroundService
    # ----------------------------------------
    # BackgroundService Section: types
    # ----------------------------------------

    # The Background Service that will be associated with the commands/events.
    # Every Background Service operates independently, but they share the same
    # API.
    enum ServiceName
      BackgroundFetch        # backgroundFetch
      BackgroundSync         # backgroundSync
      PushMessaging          # pushMessaging
      Notifications          # notifications
      PaymentHandler         # paymentHandler
      PeriodicBackgroundSync # periodicBackgroundSync
    end

    # A key-value pair for additional event information to pass along.
    struct EventMetadata
      include JSON::Serializable
      getter key : String
      getter value : String
    end

    struct BackgroundServiceEvent
      include JSON::Serializable
      # Timestamp of the event (in seconds).
      getter timestamp : Network::TimeSinceEpoch
      # The origin this event belongs to.
      getter origin : String
      @[JSON::Field(key: "serviceWorkerRegistrationId")]
      # The Service Worker ID that initiated the event.
      getter service_worker_registration_id : ServiceWorker::RegistrationID
      # The Background Service this event belongs to.
      getter service : ServiceName
      @[JSON::Field(key: "eventName")]
      # A description of the event.
      getter event_name : String
      @[JSON::Field(key: "instanceId")]
      # An identifier that groups related events together.
      getter instance_id : String
      @[JSON::Field(key: "eventMetadata")]
      # A list of event-specific information.
      getter event_metadata : Array(EventMetadata)
    end

    # ----------------------------------------
    # BackgroundService Section: commands
    # ----------------------------------------

    # Enables event updates for the service.
    struct StartObserving
      include Protocol::Command
      include JSON::Serializable
    end

    # Disables event updates for the service.
    struct StopObserving
      include Protocol::Command
      include JSON::Serializable
    end

    # Set the recording state for the service.
    struct SetRecording
      include Protocol::Command
      include JSON::Serializable
    end

    # Clears all stored data for the service.
    struct ClearEvents
      include Protocol::Command
      include JSON::Serializable
    end

    # ----------------------------------------
    # BackgroundService Section: events
    # ----------------------------------------

    # Called when the recording state for the service has been updated.
    struct RecordingStateChanged
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "isRecording")]
      getter is_recording : Bool
      getter service : ServiceName
    end

    # Called with all existing backgroundServiceEvents when enabled, and all new
    # events afterwards if enabled and recording.
    struct BackgroundServiceEventReceived
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "backgroundServiceEvent")]
      getter background_service_event : BackgroundServiceEvent
    end
  end
end
