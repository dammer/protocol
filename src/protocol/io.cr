# =========================================================
# Input/Output operations for streams produced by DevTools.
# =========================================================

# common Command module
require "./command"

module Protocol
  module IO
    # ----------------------------------------
    # IO Section: types
    # ----------------------------------------

    # This is either obtained from another method or specified as `blob:&lt;uuid&gt;` where
    # `&lt;uuid&gt` is an UUID of a Blob.
    alias StreamHandle = String

    # ----------------------------------------
    # IO Section: commands
    # ----------------------------------------

    # Close the stream, discard any temporary backing storage.
    struct Close
      include Protocol::Command
      include JSON::Serializable
    end

    # Read a chunk of the stream
    struct Read
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "base64Encoded")]
      # Set if the data is base64-encoded
      getter base64_encoded : Bool?
      # Data that were read.
      getter data : String
      # Set if the end-of-file condition occurred while reading.
      getter eof : Bool
    end

    # Return UUID of Blob object specified by a remote object id.
    struct ResolveBlob
      include Protocol::Command
      include JSON::Serializable
      # UUID of the specified Blob.
      getter uuid : String
    end
  end
end
