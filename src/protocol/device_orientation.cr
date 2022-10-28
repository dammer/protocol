# common Command module
require "./command"

module Protocol
  module DeviceOrientation
    # ----------------------------------------
    # DeviceOrientation Section: commands
    # ----------------------------------------

    # Clears the overridden Device Orientation.
    struct ClearDeviceOrientationOverride
      include Protocol::Command
      include JSON::Serializable
    end

    # Overrides the Device Orientation.
    struct SetDeviceOrientationOverride
      include Protocol::Command
      include JSON::Serializable
    end
  end
end
