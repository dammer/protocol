# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module Performance
    # ----------------------------------------
    # Performance Section: types
    # ----------------------------------------

    # Run-time execution metric.
    struct Metric
      include JSON::Serializable
      # Metric name.
      getter name : String
      # Metric value.
      getter value : Number::Primitive
    end

    # ----------------------------------------
    # Performance Section: commands
    # ----------------------------------------

    # Disable collecting and reporting metrics.
    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    # Enable collecting and reporting metrics.
    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    # Sets time domain to use for collecting and reporting duration metrics.
    # Note that this must be called before enabling metrics collection. Calling
    # this method while metrics collection is enabled returns an error.
    struct SetTimeDomain
      include Protocol::Command
      include JSON::Serializable
    end

    # Retrieve current values of run-time metrics.
    struct GetMetrics
      include Protocol::Command
      include JSON::Serializable
      # Current values for run-time metrics.
      getter metrics : Array(Metric)
    end

    # ----------------------------------------
    # Performance Section: events
    # ----------------------------------------

    # Current values of the metrics.
    struct Metrics
      include JSON::Serializable
      include Protocol::Event
      # Current values of the metrics.
      getter metrics : Array(Metric)
      # Timestamp title.
      getter title : String
    end
  end
end
