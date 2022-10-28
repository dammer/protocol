# ================================================================================
# The SystemInfo domain defines methods and events for querying low-level system information.
# ================================================================================

# common Command module
require "./command"

module Protocol
  module SystemInfo
    # ----------------------------------------
    # SystemInfo Section: types
    # ----------------------------------------

    # Describes a single graphics processor (GPU).
    struct GPUDevice
      include JSON::Serializable
      @[JSON::Field(key: "vendorId")]
      # PCI ID of the GPU vendor, if available; 0 otherwise.
      getter vendor_id : Number::Primitive
      @[JSON::Field(key: "deviceId")]
      # PCI ID of the GPU device, if available; 0 otherwise.
      getter device_id : Number::Primitive
      @[JSON::Field(key: "subSysId")]
      # Sub sys ID of the GPU, only available on Windows.
      getter sub_sys_id : Number::Primitive?
      # Revision of the GPU, only available on Windows.
      getter revision : Number::Primitive?
      @[JSON::Field(key: "vendorString")]
      # String description of the GPU vendor, if the PCI ID is not available.
      getter vendor_string : String
      @[JSON::Field(key: "deviceString")]
      # String description of the GPU device, if the PCI ID is not available.
      getter device_string : String
      @[JSON::Field(key: "driverVendor")]
      # String description of the GPU driver vendor.
      getter driver_vendor : String
      @[JSON::Field(key: "driverVersion")]
      # String description of the GPU driver version.
      getter driver_version : String
    end

    # Describes the width and height dimensions of an entity.
    struct Size
      include JSON::Serializable
      # Width in pixels.
      getter width : Int::Primitive
      # Height in pixels.
      getter height : Int::Primitive
    end

    # Describes a supported video decoding profile with its associated minimum and
    # maximum resolutions.
    struct VideoDecodeAcceleratorCapability
      include JSON::Serializable
      # Video codec profile that is supported, e.g. VP9 Profile 2.
      getter profile : String
      @[JSON::Field(key: "maxResolution")]
      # Maximum video dimensions in pixels supported for this |profile|.
      getter max_resolution : Size
      @[JSON::Field(key: "minResolution")]
      # Minimum video dimensions in pixels supported for this |profile|.
      getter min_resolution : Size
    end

    # Describes a supported video encoding profile with its associated maximum
    # resolution and maximum framerate.
    struct VideoEncodeAcceleratorCapability
      include JSON::Serializable
      # Video codec profile that is supported, e.g H264 Main.
      getter profile : String
      @[JSON::Field(key: "maxResolution")]
      # Maximum video dimensions in pixels supported for this |profile|.
      getter max_resolution : Size
      @[JSON::Field(key: "maxFramerateNumerator")]
      # Maximum encoding framerate in frames per second supported for this
      # |profile|, as fraction's numerator and denominator, e.g. 24/1 fps,
      # 24000/1001 fps, etc.
      getter max_framerate_numerator : Int::Primitive
      @[JSON::Field(key: "maxFramerateDenominator")]
      getter max_framerate_denominator : Int::Primitive
    end

    # YUV subsampling type of the pixels of a given image.
    enum SubsamplingFormat
      Yuv420 # yuv420
      Yuv422 # yuv422
      Yuv444 # yuv444
    end

    # Image format of a given image.
    enum ImageType
      Jpeg    # jpeg
      Webp    # webp
      Unknown # unknown
    end

    # Describes a supported image decoding profile with its associated minimum and
    # maximum resolutions and subsampling.
    struct ImageDecodeAcceleratorCapability
      include JSON::Serializable
      @[JSON::Field(key: "imageType")]
      # Image coded, e.g. Jpeg.
      getter image_type : ImageType
      @[JSON::Field(key: "maxDimensions")]
      # Maximum supported dimensions of the image in pixels.
      getter max_dimensions : Size
      @[JSON::Field(key: "minDimensions")]
      # Minimum supported dimensions of the image in pixels.
      getter min_dimensions : Size
      # Optional array of supported subsampling formats, e.g. 4:2:0, if known.
      getter subsamplings : Array(SubsamplingFormat)
    end

    # Provides information about the GPU(s) on the system.
    struct GPUInfo
      include JSON::Serializable
      # The graphics devices on the system. Element 0 is the primary GPU.
      getter devices : Array(GPUDevice)
      @[JSON::Field(key: "auxAttributes")]
      # An optional dictionary of additional GPU related attributes.
      getter aux_attributes : JSON::Any?
      @[JSON::Field(key: "featureStatus")]
      # An optional dictionary of graphics features and their status.
      getter feature_status : JSON::Any?
      @[JSON::Field(key: "driverBugWorkarounds")]
      # An optional array of GPU driver bug workarounds.
      getter driver_bug_workarounds : Array(String)
      @[JSON::Field(key: "videoDecoding")]
      # Supported accelerated video decoding capabilities.
      getter video_decoding : Array(VideoDecodeAcceleratorCapability)
      @[JSON::Field(key: "videoEncoding")]
      # Supported accelerated video encoding capabilities.
      getter video_encoding : Array(VideoEncodeAcceleratorCapability)
      @[JSON::Field(key: "imageDecoding")]
      # Supported accelerated image decoding capabilities.
      getter image_decoding : Array(ImageDecodeAcceleratorCapability)
    end

    # Represents process info.
    struct ProcessInfo
      include JSON::Serializable
      # Specifies process type.
      getter type : String
      # Specifies process id.
      getter id : Int::Primitive
      @[JSON::Field(key: "cpuTime")]
      # Specifies cumulative CPU usage in seconds across all threads of the
      # process since the process start.
      getter cpu_time : Number::Primitive
    end

    # ----------------------------------------
    # SystemInfo Section: commands
    # ----------------------------------------

    # Returns information about the system.
    struct GetInfo
      include Protocol::Command
      include JSON::Serializable
      # Information about the GPUs on the system.
      getter gpu : GPUInfo
      @[JSON::Field(key: "modelName")]
      # A platform-dependent description of the model of the machine. On Mac OS, this is, for
      # example, 'MacBookPro'. Will be the empty string if not supported.
      getter model_name : String
      @[JSON::Field(key: "modelVersion")]
      # A platform-dependent description of the version of the machine. On Mac OS, this is, for
      # example, '10.1'. Will be the empty string if not supported.
      getter model_version : String
      @[JSON::Field(key: "commandLine")]
      # The command line string used to launch the browser. Will be the empty string if not
      # supported.
      getter command_line : String
    end

    # Returns information about all running processes.
    struct GetProcessInfo
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "processInfo")]
      # An array of process info blocks.
      getter process_info : Array(ProcessInfo)
    end
  end
end
