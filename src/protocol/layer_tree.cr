# LayerTree module dependencies
require "./dom"

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module LayerTree
    # ----------------------------------------
    # LayerTree Section: types
    # ----------------------------------------

    # Unique Layer identifier.
    alias LayerId = String

    # Unique snapshot identifier.
    alias SnapshotId = String

    # Rectangle where scrolling happens on the main thread.
    struct ScrollRect
      include JSON::Serializable
      # Rectangle itself.
      getter rect : DOM::Rect
      # Reason for rectangle to force scrolling on the main thread
      getter type : String
    end

    # Sticky position constraints.
    struct StickyPositionConstraint
      include JSON::Serializable
      @[JSON::Field(key: "stickyBoxRect")]
      # Layout rectangle of the sticky element before being shifted
      getter sticky_box_rect : DOM::Rect
      @[JSON::Field(key: "containingBlockRect")]
      # Layout rectangle of the containing block of the sticky element
      getter containing_block_rect : DOM::Rect
      @[JSON::Field(key: "nearestLayerShiftingStickyBox")]
      # The nearest sticky layer that shifts the sticky box
      getter nearest_layer_shifting_sticky_box : LayerId?
      @[JSON::Field(key: "nearestLayerShiftingContainingBlock")]
      # The nearest sticky layer that shifts the containing block
      getter nearest_layer_shifting_containing_block : LayerId?
    end

    # Serialized fragment of layer picture along with its offset within the layer.
    struct PictureTile
      include JSON::Serializable
      # Offset from owning layer left boundary
      getter x : Number::Primitive
      # Offset from owning layer top boundary
      getter y : Number::Primitive
      # Base64-encoded snapshot data. (Encoded as a base64 string when passed over JSON)
      getter picture : String
    end

    # Information about a compositing layer.
    struct Layer
      include JSON::Serializable
      @[JSON::Field(key: "layerId")]
      # The unique id for this layer.
      getter layer_id : LayerId
      @[JSON::Field(key: "parentLayerId")]
      # The id of parent (not present for root).
      getter parent_layer_id : LayerId?
      @[JSON::Field(key: "backendNodeId")]
      # The backend id for the node associated with this layer.
      getter backend_node_id : DOM::BackendNodeId?
      @[JSON::Field(key: "offsetX")]
      # Offset from parent layer, X coordinate.
      getter offset_x : Number::Primitive
      @[JSON::Field(key: "offsetY")]
      # Offset from parent layer, Y coordinate.
      getter offset_y : Number::Primitive
      # Layer width.
      getter width : Number::Primitive
      # Layer height.
      getter height : Number::Primitive
      # Transformation matrix for layer, default is identity matrix
      getter transform : Array(Number::Primitive)?
      @[JSON::Field(key: "anchorX")]
      # Transform anchor point X, absent if no transform specified
      getter anchor_x : Number::Primitive?
      @[JSON::Field(key: "anchorY")]
      # Transform anchor point Y, absent if no transform specified
      getter anchor_y : Number::Primitive?
      @[JSON::Field(key: "anchorZ")]
      # Transform anchor point Z, absent if no transform specified
      getter anchor_z : Number::Primitive?
      @[JSON::Field(key: "paintCount")]
      # Indicates how many time this layer has painted.
      getter paint_count : Int::Primitive
      @[JSON::Field(key: "drawsContent")]
      # Indicates whether this layer hosts any content, rather than being used for
      # transform/scrolling purposes only.
      getter draws_content : Bool
      # Set if layer is not visible.
      getter invisible : Bool?
      @[JSON::Field(key: "scrollRects")]
      # Rectangles scrolling on main thread only.
      getter scroll_rects : Array(ScrollRect)?
      @[JSON::Field(key: "stickyPositionConstraint")]
      # Sticky position constraint information
      getter sticky_position_constraint : StickyPositionConstraint?
    end

    # Array of timings, one per paint step.
    alias PaintProfile = Array(Number::Primitive)

    # ----------------------------------------
    # LayerTree Section: commands
    # ----------------------------------------

    # Provides the reasons why the given layer was composited.
    struct CompositingReasons
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "compositingReasons")]
      # A list of strings specifying reasons for the given layer to become composited.
      getter compositing_reasons : Array(String)
      @[JSON::Field(key: "compositingReasonIds")]
      # A list of strings specifying reason IDs for the given layer to become composited.
      getter compositing_reason_ids : Array(String)
    end

    # Disables compositing tree inspection.
    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    # Enables compositing tree inspection.
    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    # Returns the snapshot identifier.
    struct LoadSnapshot
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "snapshotId")]
      # The id of the snapshot.
      getter snapshot_id : SnapshotId
    end

    # Returns the layer snapshot identifier.
    struct MakeSnapshot
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "snapshotId")]
      # The id of the layer snapshot.
      getter snapshot_id : SnapshotId
    end

    struct ProfileSnapshot
      include Protocol::Command
      include JSON::Serializable
      # The array of paint profiles, one per run.
      getter timings : Array(PaintProfile)
    end

    # Releases layer snapshot captured by the back-end.
    struct ReleaseSnapshot
      include Protocol::Command
      include JSON::Serializable
    end

    # Replays the layer snapshot and returns the resulting bitmap.
    struct ReplaySnapshot
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "dataURL")]
      # A data: URL for resulting image.
      getter data_url : String
    end

    # Replays the layer snapshot and returns canvas log.
    struct SnapshotCommandLog
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "commandLog")]
      # The array of canvas function calls.
      getter command_log : Array(JSON::Any)
    end

    # ----------------------------------------
    # LayerTree Section: events
    # ----------------------------------------

    struct LayerPainted
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "layerId")]
      # The id of the painted layer.
      getter layer_id : LayerId
      # Clip rectangle.
      getter clip : DOM::Rect
    end

    struct LayerTreeDidChange
      include JSON::Serializable
      include Protocol::Event
      # Layer tree, absent if not in the comspositing mode.
      getter layers : Array(Layer)?
    end
  end
end
