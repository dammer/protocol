# ==========================
# This domain is deprecated.
# ==========================

# common Command module
require "./command"

module Protocol
  module Schema
    # ----------------------------------------
    # Schema Section: types
    # ----------------------------------------

    # Description of the protocol domain.
    struct Domain
      include JSON::Serializable
      # Domain name.
      getter name : String
      # Domain version.
      getter version : String
    end

    # ----------------------------------------
    # Schema Section: commands
    # ----------------------------------------

    # Returns supported domains.
    struct GetDomains
      include Protocol::Command
      include JSON::Serializable
      # List of supported domains.
      getter domains : Array(Domain)
    end
  end
end
