# ================================================================================
# This domain provides various functionality related to drawing atop the inspected page.
# ================================================================================

# Overlay module dependencies
require "./dom"
require "./page"
require "./runtime"

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module Overlay
    # ----------------------------------------
    # Overlay Section: types
    # ----------------------------------------

    # Configuration data for drawing the source order of an elements children.
    struct SourceOrderConfig
      include JSON::Serializable
      @[JSON::Field(key: "parentOutlineColor")]
      # the color to outline the givent element in.
      getter parent_outline_color : DOM::RGBA
      @[JSON::Field(key: "childOutlineColor")]
      # the color to outline the child elements in.
      getter child_outline_color : DOM::RGBA
    end

    # Configuration data for the highlighting of Grid elements.
    struct GridHighlightConfig
      include JSON::Serializable
      @[JSON::Field(key: "showGridExtensionLines")]
      # Whether the extension lines from grid cells to the rulers should be shown (default: false).
      getter show_grid_extension_lines : Bool?
      @[JSON::Field(key: "showPositiveLineNumbers")]
      # Show Positive line number labels (default: false).
      getter show_positive_line_numbers : Bool?
      @[JSON::Field(key: "showNegativeLineNumbers")]
      # Show Negative line number labels (default: false).
      getter show_negative_line_numbers : Bool?
      @[JSON::Field(key: "showAreaNames")]
      # Show area name labels (default: false).
      getter show_area_names : Bool?
      @[JSON::Field(key: "showLineNames")]
      # Show line name labels (default: false).
      getter show_line_names : Bool?
      @[JSON::Field(key: "showTrackSizes")]
      # Show track size labels (default: false).
      getter show_track_sizes : Bool?
      @[JSON::Field(key: "gridBorderColor")]
      # The grid container border highlight color (default: transparent).
      getter grid_border_color : DOM::RGBA?
      @[JSON::Field(key: "cellBorderColor")]
      # The cell border color (default: transparent). Deprecated, please use rowLineColor and columnLineColor instead.
      getter cell_border_color : DOM::RGBA?
      @[JSON::Field(key: "rowLineColor")]
      # The row line color (default: transparent).
      getter row_line_color : DOM::RGBA?
      @[JSON::Field(key: "columnLineColor")]
      # The column line color (default: transparent).
      getter column_line_color : DOM::RGBA?
      @[JSON::Field(key: "gridBorderDash")]
      # Whether the grid border is dashed (default: false).
      getter grid_border_dash : Bool?
      @[JSON::Field(key: "cellBorderDash")]
      # Whether the cell border is dashed (default: false). Deprecated, please us rowLineDash and columnLineDash instead.
      getter cell_border_dash : Bool?
      @[JSON::Field(key: "rowLineDash")]
      # Whether row lines are dashed (default: false).
      getter row_line_dash : Bool?
      @[JSON::Field(key: "columnLineDash")]
      # Whether column lines are dashed (default: false).
      getter column_line_dash : Bool?
      @[JSON::Field(key: "rowGapColor")]
      # The row gap highlight fill color (default: transparent).
      getter row_gap_color : DOM::RGBA?
      @[JSON::Field(key: "rowHatchColor")]
      # The row gap hatching fill color (default: transparent).
      getter row_hatch_color : DOM::RGBA?
      @[JSON::Field(key: "columnGapColor")]
      # The column gap highlight fill color (default: transparent).
      getter column_gap_color : DOM::RGBA?
      @[JSON::Field(key: "columnHatchColor")]
      # The column gap hatching fill color (default: transparent).
      getter column_hatch_color : DOM::RGBA?
      @[JSON::Field(key: "areaBorderColor")]
      # The named grid areas border color (Default: transparent).
      getter area_border_color : DOM::RGBA?
      @[JSON::Field(key: "gridBackgroundColor")]
      # The grid container background color (Default: transparent).
      getter grid_background_color : DOM::RGBA?
    end

    # Configuration data for the highlighting of Flex container elements.
    struct FlexContainerHighlightConfig
      include JSON::Serializable
      @[JSON::Field(key: "containerBorder")]
      # The style of the container border
      getter container_border : LineStyle?
      @[JSON::Field(key: "lineSeparator")]
      # The style of the separator between lines
      getter line_separator : LineStyle?
      @[JSON::Field(key: "itemSeparator")]
      # The style of the separator between items
      getter item_separator : LineStyle?
      @[JSON::Field(key: "mainDistributedSpace")]
      # Style of content-distribution space on the main axis (justify-content).
      getter main_distributed_space : BoxStyle?
      @[JSON::Field(key: "crossDistributedSpace")]
      # Style of content-distribution space on the cross axis (align-content).
      getter cross_distributed_space : BoxStyle?
      @[JSON::Field(key: "rowGapSpace")]
      # Style of empty space caused by row gaps (gap/row-gap).
      getter row_gap_space : BoxStyle?
      @[JSON::Field(key: "columnGapSpace")]
      # Style of empty space caused by columns gaps (gap/column-gap).
      getter column_gap_space : BoxStyle?
      @[JSON::Field(key: "crossAlignment")]
      # Style of the self-alignment line (align-items).
      getter cross_alignment : LineStyle?
    end

    # Configuration data for the highlighting of Flex item elements.
    struct FlexItemHighlightConfig
      include JSON::Serializable
      @[JSON::Field(key: "baseSizeBox")]
      # Style of the box representing the item's base size
      getter base_size_box : BoxStyle?
      @[JSON::Field(key: "baseSizeBorder")]
      # Style of the border around the box representing the item's base size
      getter base_size_border : LineStyle?
      @[JSON::Field(key: "flexibilityArrow")]
      # Style of the arrow representing if the item grew or shrank
      getter flexibility_arrow : LineStyle?
    end

    # Style information for drawing a line.
    struct LineStyle
      include JSON::Serializable
      # The color of the line (default: transparent)
      getter color : DOM::RGBA?
      # The line pattern (default: solid)
      getter pattern : String?
    end

    # Style information for drawing a box.
    struct BoxStyle
      include JSON::Serializable
      @[JSON::Field(key: "fillColor")]
      # The background color for the box (default: transparent)
      getter fill_color : DOM::RGBA?
      @[JSON::Field(key: "hatchColor")]
      # The hatching color for the box (default: transparent)
      getter hatch_color : DOM::RGBA?
    end

    enum ContrastAlgorithm
      Aa   # aa
      Aaa  # aaa
      Apca # apca
    end

    # Configuration data for the highlighting of page elements.
    struct HighlightConfig
      include JSON::Serializable
      @[JSON::Field(key: "showInfo")]
      # Whether the node info tooltip should be shown (default: false).
      getter show_info : Bool?
      @[JSON::Field(key: "showStyles")]
      # Whether the node styles in the tooltip (default: false).
      getter show_styles : Bool?
      @[JSON::Field(key: "showRulers")]
      # Whether the rulers should be shown (default: false).
      getter show_rulers : Bool?
      @[JSON::Field(key: "showAccessibilityInfo")]
      # Whether the a11y info should be shown (default: true).
      getter show_accessibility_info : Bool?
      @[JSON::Field(key: "showExtensionLines")]
      # Whether the extension lines from node to the rulers should be shown (default: false).
      getter show_extension_lines : Bool?
      @[JSON::Field(key: "contentColor")]
      # The content box highlight fill color (default: transparent).
      getter content_color : DOM::RGBA?
      @[JSON::Field(key: "paddingColor")]
      # The padding highlight fill color (default: transparent).
      getter padding_color : DOM::RGBA?
      @[JSON::Field(key: "borderColor")]
      # The border highlight fill color (default: transparent).
      getter border_color : DOM::RGBA?
      @[JSON::Field(key: "marginColor")]
      # The margin highlight fill color (default: transparent).
      getter margin_color : DOM::RGBA?
      @[JSON::Field(key: "eventTargetColor")]
      # The event target element highlight fill color (default: transparent).
      getter event_target_color : DOM::RGBA?
      @[JSON::Field(key: "shapeColor")]
      # The shape outside fill color (default: transparent).
      getter shape_color : DOM::RGBA?
      @[JSON::Field(key: "shapeMarginColor")]
      # The shape margin fill color (default: transparent).
      getter shape_margin_color : DOM::RGBA?
      @[JSON::Field(key: "cssGridColor")]
      # The grid layout color (default: transparent).
      getter css_grid_color : DOM::RGBA?
      @[JSON::Field(key: "colorFormat")]
      # The color format used to format color styles (default: hex).
      getter color_format : ColorFormat?
      @[JSON::Field(key: "gridHighlightConfig")]
      # The grid layout highlight configuration (default: all transparent).
      getter grid_highlight_config : GridHighlightConfig?
      @[JSON::Field(key: "flexContainerHighlightConfig")]
      # The flex container highlight configuration (default: all transparent).
      getter flex_container_highlight_config : FlexContainerHighlightConfig?
      @[JSON::Field(key: "flexItemHighlightConfig")]
      # The flex item highlight configuration (default: all transparent).
      getter flex_item_highlight_config : FlexItemHighlightConfig?
      @[JSON::Field(key: "contrastAlgorithm")]
      # The contrast algorithm to use for the contrast ratio (default: aa).
      getter contrast_algorithm : ContrastAlgorithm?
      @[JSON::Field(key: "containerQueryContainerHighlightConfig")]
      # The container query container highlight configuration (default: all transparent).
      getter container_query_container_highlight_config : ContainerQueryContainerHighlightConfig?
    end

    enum ColorFormat
      Rgb # rgb
      Hsl # hsl
      Hwb # hwb
      Hex # hex
    end

    # Configurations for Persistent Grid Highlight
    struct GridNodeHighlightConfig
      include JSON::Serializable
      @[JSON::Field(key: "gridHighlightConfig")]
      # A descriptor for the highlight appearance.
      getter grid_highlight_config : GridHighlightConfig
      @[JSON::Field(key: "nodeId")]
      # Identifier of the node to highlight.
      getter node_id : DOM::NodeId
    end

    struct FlexNodeHighlightConfig
      include JSON::Serializable
      @[JSON::Field(key: "flexContainerHighlightConfig")]
      # A descriptor for the highlight appearance of flex containers.
      getter flex_container_highlight_config : FlexContainerHighlightConfig
      @[JSON::Field(key: "nodeId")]
      # Identifier of the node to highlight.
      getter node_id : DOM::NodeId
    end

    struct ScrollSnapContainerHighlightConfig
      include JSON::Serializable
      @[JSON::Field(key: "snapportBorder")]
      # The style of the snapport border (default: transparent)
      getter snapport_border : LineStyle?
      @[JSON::Field(key: "snapAreaBorder")]
      # The style of the snap area border (default: transparent)
      getter snap_area_border : LineStyle?
      @[JSON::Field(key: "scrollMarginColor")]
      # The margin highlight fill color (default: transparent).
      getter scroll_margin_color : DOM::RGBA?
      @[JSON::Field(key: "scrollPaddingColor")]
      # The padding highlight fill color (default: transparent).
      getter scroll_padding_color : DOM::RGBA?
    end

    struct ScrollSnapHighlightConfig
      include JSON::Serializable
      @[JSON::Field(key: "scrollSnapContainerHighlightConfig")]
      # A descriptor for the highlight appearance of scroll snap containers.
      getter scroll_snap_container_highlight_config : ScrollSnapContainerHighlightConfig
      @[JSON::Field(key: "nodeId")]
      # Identifier of the node to highlight.
      getter node_id : DOM::NodeId
    end

    # Configuration for dual screen hinge
    struct HingeConfig
      include JSON::Serializable
      # A rectangle represent hinge
      getter rect : DOM::Rect
      @[JSON::Field(key: "contentColor")]
      # The content box highlight fill color (default: a dark color).
      getter content_color : DOM::RGBA?
      @[JSON::Field(key: "outlineColor")]
      # The content box highlight outline color (default: transparent).
      getter outline_color : DOM::RGBA?
    end

    struct ContainerQueryHighlightConfig
      include JSON::Serializable
      @[JSON::Field(key: "containerQueryContainerHighlightConfig")]
      # A descriptor for the highlight appearance of container query containers.
      getter container_query_container_highlight_config : ContainerQueryContainerHighlightConfig
      @[JSON::Field(key: "nodeId")]
      # Identifier of the container node to highlight.
      getter node_id : DOM::NodeId
    end

    struct ContainerQueryContainerHighlightConfig
      include JSON::Serializable
      @[JSON::Field(key: "containerBorder")]
      # The style of the container border.
      getter container_border : LineStyle?
      @[JSON::Field(key: "descendantBorder")]
      # The style of the descendants' borders.
      getter descendant_border : LineStyle?
    end

    struct IsolatedElementHighlightConfig
      include JSON::Serializable
      @[JSON::Field(key: "isolationModeHighlightConfig")]
      # A descriptor for the highlight appearance of an element in isolation mode.
      getter isolation_mode_highlight_config : IsolationModeHighlightConfig
      @[JSON::Field(key: "nodeId")]
      # Identifier of the isolated element to highlight.
      getter node_id : DOM::NodeId
    end

    struct IsolationModeHighlightConfig
      include JSON::Serializable
      @[JSON::Field(key: "resizerColor")]
      # The fill color of the resizers (default: transparent).
      getter resizer_color : DOM::RGBA?
      @[JSON::Field(key: "resizerHandleColor")]
      # The fill color for resizer handles (default: transparent).
      getter resizer_handle_color : DOM::RGBA?
      @[JSON::Field(key: "maskColor")]
      # The fill color for the mask covering non-isolated elements (default: transparent).
      getter mask_color : DOM::RGBA?
    end

    enum InspectMode
      SearchForNode         # searchForNode
      SearchForUAShadowDOM  # searchForUAShadowDOM
      CaptureAreaScreenshot # captureAreaScreenshot
      ShowDistances         # showDistances
      None                  # none
    end

    # ----------------------------------------
    # Overlay Section: commands
    # ----------------------------------------

    # Disables domain notifications.
    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    # Enables domain notifications.
    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    # For testing.
    struct GetHighlightObjectForTest
      include Protocol::Command
      include JSON::Serializable
      # Highlight data for the node.
      getter highlight : JSON::Any
    end

    # For Persistent Grid testing.
    struct GetGridHighlightObjectsForTest
      include Protocol::Command
      include JSON::Serializable
      # Grid Highlight data for the node ids provided.
      getter highlights : JSON::Any
    end

    # For Source Order Viewer testing.
    struct GetSourceOrderHighlightObjectForTest
      include Protocol::Command
      include JSON::Serializable
      # Source order highlight data for the node id provided.
      getter highlight : JSON::Any
    end

    # Hides any highlight.
    struct HideHighlight
      include Protocol::Command
      include JSON::Serializable
    end

    # Highlights owner element of the frame with given id.
    # Deprecated: Doesn't work reliablity and cannot be fixed due to process
    # separatation (the owner node might be in a different process). Determine
    # the owner node in the client and use highlightNode.
    struct HighlightFrame
      include Protocol::Command
      include JSON::Serializable
    end

    # Highlights DOM node with given id or with the given JavaScript object wrapper. Either nodeId or
    # objectId must be specified.
    struct HighlightNode
      include Protocol::Command
      include JSON::Serializable
    end

    # Highlights given quad. Coordinates are absolute with respect to the main frame viewport.
    struct HighlightQuad
      include Protocol::Command
      include JSON::Serializable
    end

    # Highlights given rectangle. Coordinates are absolute with respect to the main frame viewport.
    struct HighlightRect
      include Protocol::Command
      include JSON::Serializable
    end

    # Highlights the source order of the children of the DOM node with given id or with the given
    # JavaScript object wrapper. Either nodeId or objectId must be specified.
    struct HighlightSourceOrder
      include Protocol::Command
      include JSON::Serializable
    end

    # Enters the 'inspect' mode. In this mode, elements that user is hovering over are highlighted.
    # Backend then generates 'inspectNodeRequested' event upon element selection.
    struct SetInspectMode
      include Protocol::Command
      include JSON::Serializable
    end

    # Highlights owner element of all frames detected to be ads.
    struct SetShowAdHighlights
      include Protocol::Command
      include JSON::Serializable
    end

    struct SetPausedInDebuggerMessage
      include Protocol::Command
      include JSON::Serializable
    end

    # Requests that backend shows debug borders on layers
    struct SetShowDebugBorders
      include Protocol::Command
      include JSON::Serializable
    end

    # Requests that backend shows the FPS counter
    struct SetShowFPSCounter
      include Protocol::Command
      include JSON::Serializable
    end

    # Highlight multiple elements with the CSS Grid overlay.
    struct SetShowGridOverlays
      include Protocol::Command
      include JSON::Serializable
    end

    struct SetShowFlexOverlays
      include Protocol::Command
      include JSON::Serializable
    end

    struct SetShowScrollSnapOverlays
      include Protocol::Command
      include JSON::Serializable
    end

    struct SetShowContainerQueryOverlays
      include Protocol::Command
      include JSON::Serializable
    end

    # Requests that backend shows paint rectangles
    struct SetShowPaintRects
      include Protocol::Command
      include JSON::Serializable
    end

    # Requests that backend shows layout shift regions
    struct SetShowLayoutShiftRegions
      include Protocol::Command
      include JSON::Serializable
    end

    # Requests that backend shows scroll bottleneck rects
    struct SetShowScrollBottleneckRects
      include Protocol::Command
      include JSON::Serializable
    end

    # Deprecated, no longer has any effect.
    struct SetShowHitTestBorders
      include Protocol::Command
      include JSON::Serializable
    end

    # Request that backend shows an overlay with web vital metrics.
    struct SetShowWebVitals
      include Protocol::Command
      include JSON::Serializable
    end

    # Paints viewport size upon main frame resize.
    struct SetShowViewportSizeOnResize
      include Protocol::Command
      include JSON::Serializable
    end

    # Add a dual screen device hinge
    struct SetShowHinge
      include Protocol::Command
      include JSON::Serializable
    end

    # Show elements in isolation mode with overlays.
    struct SetShowIsolatedElements
      include Protocol::Command
      include JSON::Serializable
    end

    # ----------------------------------------
    # Overlay Section: events
    # ----------------------------------------

    # Fired when the node should be inspected. This happens after call to `setInspectMode` or when
    # user manually inspects an element.
    struct InspectNodeRequested
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "backendNodeId")]
      # Id of the node to inspect.
      getter backend_node_id : DOM::BackendNodeId
    end

    # Fired when the node should be highlighted. This happens after call to `setInspectMode`.
    struct NodeHighlightRequested
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "nodeId")]
      getter node_id : DOM::NodeId
    end

    # Fired when user asks to capture screenshot of some area on the page.
    struct ScreenshotRequested
      include JSON::Serializable
      include Protocol::Event
      # Viewport to capture, in device independent pixels (dip).
      getter viewport : Page::Viewport
    end

    # Fired when user cancels the inspect mode.
    struct InspectModeCanceled
      include JSON::Serializable
      include Protocol::Event
    end
  end
end
