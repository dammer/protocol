# ================================================================================
# This domain exposes DOM read/write operations. Each DOM Node is represented with its mirror object
# that has an `id`. This `id` can be used to get additional information on the Node, resolve it into
# the JavaScript object wrapper, etc. It is important that client receives DOM events only for the
# nodes that are known to the client. Backend keeps track of the nodes that were sent to the client
# and never sends the same node twice. It is client's responsibility to collect information about
# the nodes that were sent to the client.<p>Note that `iframe` owner elements will return
# corresponding document elements as their child nodes.</p>
# ================================================================================

# DOM module dependencies
require "./runtime"

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module DOM
    # ----------------------------------------
    # DOM Section: types
    # ----------------------------------------

    # Unique DOM node identifier.
    alias NodeId = Int::Primitive

    # Unique DOM node identifier used to reference a node that may not have been pushed to the
    # front-end.
    alias BackendNodeId = Int::Primitive

    # Backend node with a friendly name.
    struct BackendNode
      include JSON::Serializable
      @[JSON::Field(key: "nodeType")]
      # `Node`'s nodeType.
      getter node_type : Int::Primitive
      @[JSON::Field(key: "nodeName")]
      # `Node`'s nodeName.
      getter node_name : String
      @[JSON::Field(key: "backendNodeId")]
      getter backend_node_id : BackendNodeId
    end

    # Pseudo element type.
    @[DashEnum]
    enum PseudoType
      FirstLine                   # first-line
      FirstLetter                 # first-letter
      Before                      # before
      After                       # after
      Marker                      # marker
      Backdrop                    # backdrop
      Selection                   # selection
      TargetText                  # target-text
      SpellingError               # spelling-error
      GrammarError                # grammar-error
      Highlight                   # highlight
      FirstLineInherited          # first-line-inherited
      Scrollbar                   # scrollbar
      ScrollbarThumb              # scrollbar-thumb
      ScrollbarButton             # scrollbar-button
      ScrollbarTrack              # scrollbar-track
      ScrollbarTrackPiece         # scrollbar-track-piece
      ScrollbarCorner             # scrollbar-corner
      Resizer                     # resizer
      InputListButton             # input-list-button
      PageTransition              # page-transition
      PageTransitionContainer     # page-transition-container
      PageTransitionImageWrapper  # page-transition-image-wrapper
      PageTransitionOutgoingImage # page-transition-outgoing-image
      PageTransitionIncomingImage # page-transition-incoming-image
    end

    # Shadow root type.
    @[DashEnum]
    enum ShadowRootType
      UserAgent # user-agent
      Open      # open
      Closed    # closed
    end

    # Document compatibility mode.
    enum CompatibilityMode
      QuirksMode        # QuirksMode
      LimitedQuirksMode # LimitedQuirksMode
      NoQuirksMode      # NoQuirksMode
    end

    # DOM interaction is implemented in terms of mirror objects that represent the actual DOM nodes.
    # DOMNode is a base node mirror type.
    class Node
      include JSON::Serializable
      @[JSON::Field(key: "nodeId")]
      # Node identifier that is passed into the rest of the DOM messages as the `nodeId`. Backend
      # will only push node with given `id` once. It is aware of all requested nodes and will only
      # fire DOM events for nodes known to the client.
      getter node_id : NodeId
      @[JSON::Field(key: "parentId")]
      # The id of the parent node if any.
      getter parent_id : NodeId?
      @[JSON::Field(key: "backendNodeId")]
      # The BackendNodeId for this node.
      getter backend_node_id : BackendNodeId
      @[JSON::Field(key: "nodeType")]
      # `Node`'s nodeType.
      getter node_type : Int::Primitive
      @[JSON::Field(key: "nodeName")]
      # `Node`'s nodeName.
      getter node_name : String
      @[JSON::Field(key: "localName")]
      # `Node`'s localName.
      getter local_name : String
      @[JSON::Field(key: "nodeValue")]
      # `Node`'s nodeValue.
      getter node_value : String
      @[JSON::Field(key: "childNodeCount")]
      # Child count for `Container` nodes.
      getter child_node_count : Int::Primitive?
      # Child nodes of this node when requested with children.
      getter children : Array(Node)?
      # Attributes of the `Element` node in the form of flat array `[name1, value1, name2, value2]`.
      getter attributes : Array(String)?
      @[JSON::Field(key: "documentURL")]
      # Document URL that `Document` or `FrameOwner` node points to.
      getter document_url : String?
      @[JSON::Field(key: "baseURL")]
      # Base URL that `Document` or `FrameOwner` node uses for URL completion.
      getter base_url : String?
      @[JSON::Field(key: "publicId")]
      # `DocumentType`'s publicId.
      getter public_id : String?
      @[JSON::Field(key: "systemId")]
      # `DocumentType`'s systemId.
      getter system_id : String?
      @[JSON::Field(key: "internalSubset")]
      # `DocumentType`'s internalSubset.
      getter internal_subset : String?
      @[JSON::Field(key: "xmlVersion")]
      # `Document`'s XML version in case of XML documents.
      getter xml_version : String?
      # `Attr`'s name.
      getter name : String?
      # `Attr`'s value.
      getter value : String?
      @[JSON::Field(key: "pseudoType")]
      # Pseudo element type for this node.
      getter pseudo_type : PseudoType?
      @[JSON::Field(key: "pseudoIdentifier")]
      # Pseudo element identifier for this node. Only present if there is a
      # valid pseudoType.
      getter pseudo_identifier : String?
      @[JSON::Field(key: "shadowRootType")]
      # Shadow root type.
      getter shadow_root_type : ShadowRootType?
      @[JSON::Field(key: "frameId")]
      # Frame ID for frame owner elements.
      getter frame_id : Page::FrameId?
      @[JSON::Field(key: "contentDocument")]
      # Content document for frame owner elements.
      getter content_document : Node?
      @[JSON::Field(key: "shadowRoots")]
      # Shadow root list for given element host.
      getter shadow_roots : Array(Node)?
      @[JSON::Field(key: "templateContent")]
      # Content document fragment for template elements.
      getter template_content : Node?
      @[JSON::Field(key: "pseudoElements")]
      # Pseudo elements associated with this node.
      getter pseudo_elements : Array(Node)?
      @[JSON::Field(key: "importedDocument")]
      # Deprecated, as the HTML Imports API has been removed (crbug.com/937746).
      # This property used to return the imported document for the HTMLImport links.
      # The property is always undefined now.
      getter imported_document : Node?
      @[JSON::Field(key: "distributedNodes")]
      # Distributed nodes for given insertion point.
      getter distributed_nodes : Array(BackendNode)?
      @[JSON::Field(key: "isSVG")]
      # Whether the node is SVG.
      getter is_svg : Bool?
      @[JSON::Field(key: "compatibilityMode")]
      getter compatibility_mode : CompatibilityMode?
      @[JSON::Field(key: "assignedSlot")]
      getter assigned_slot : BackendNode?
    end

    # A structure holding an RGBA color.
    struct RGBA
      include JSON::Serializable
      # The red component, in the [0-255] range.
      getter r : Int::Primitive
      # The green component, in the [0-255] range.
      getter g : Int::Primitive
      # The blue component, in the [0-255] range.
      getter b : Int::Primitive
      # The alpha component, in the [0-1] range (default: 1).
      getter a : Number::Primitive?
    end

    # An array of quad vertices, x immediately followed by y for each point, points clock-wise.
    alias Quad = Array(Number::Primitive)

    # Box model.
    struct BoxModel
      include JSON::Serializable
      # Content box
      getter content : Quad
      # Padding box
      getter padding : Quad
      # Border box
      getter border : Quad
      # Margin box
      getter margin : Quad
      # Node width
      getter width : Int::Primitive
      # Node height
      getter height : Int::Primitive
      @[JSON::Field(key: "shapeOutside")]
      # Shape outside coordinates
      getter shape_outside : ShapeOutsideInfo?
    end

    # CSS Shape Outside details.
    struct ShapeOutsideInfo
      include JSON::Serializable
      # Shape bounds
      getter bounds : Quad
      # Shape coordinate details
      getter shape : Array(JSON::Any)
      @[JSON::Field(key: "marginShape")]
      # Margin shape bounds
      getter margin_shape : Array(JSON::Any)
    end

    # Rectangle.
    struct Rect
      include JSON::Serializable
      # X coordinate
      getter x : Number::Primitive
      # Y coordinate
      getter y : Number::Primitive
      # Rectangle width
      getter width : Number::Primitive
      # Rectangle height
      getter height : Number::Primitive
    end

    struct CSSComputedStyleProperty
      include JSON::Serializable
      # Computed style property name.
      getter name : String
      # Computed style property value.
      getter value : String
    end

    # ----------------------------------------
    # DOM Section: commands
    # ----------------------------------------

    # Collects class names for the node with given id and all of it's child nodes.
    struct CollectClassNamesFromSubtree
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "classNames")]
      # Class name list.
      getter class_names : Array(String)
    end

    # Creates a deep copy of the specified node and places it into the target container before the
    # given anchor.
    struct CopyTo
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "nodeId")]
      # Id of the node clone.
      getter node_id : NodeId
    end

    # Describes node given its id, does not require domain to be enabled. Does not start tracking any
    # objects, can be used for automation.
    struct DescribeNode
      include Protocol::Command
      include JSON::Serializable
      # Node description.
      getter node : Node
    end

    # Scrolls the specified rect of the given node into view if not already visible.
    # Note: exactly one between nodeId, backendNodeId and objectId should be passed
    # to identify the node.
    struct ScrollIntoViewIfNeeded
      include Protocol::Command
      include JSON::Serializable
    end

    # Disables DOM agent for the given page.
    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    # Discards search results from the session with the given id. `getSearchResults` should no longer
    # be called for that search.
    struct DiscardSearchResults
      include Protocol::Command
      include JSON::Serializable
    end

    # Enables DOM agent for the given page.
    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    # Focuses the given element.
    struct Focus
      include Protocol::Command
      include JSON::Serializable
    end

    # Returns attributes for the specified node.
    struct GetAttributes
      include Protocol::Command
      include JSON::Serializable
      # An interleaved array of node attribute names and values.
      getter attributes : Array(String)
    end

    # Returns boxes for the given node.
    struct GetBoxModel
      include Protocol::Command
      include JSON::Serializable
      # Box model for the node.
      getter model : BoxModel
    end

    # Returns quads that describe node position on the page. This method
    # might return multiple quads for inline nodes.
    struct GetContentQuads
      include Protocol::Command
      include JSON::Serializable
      # Quads that describe node layout relative to viewport.
      getter quads : Array(Quad)
    end

    # Returns the root DOM node (and optionally the subtree) to the caller.
    struct GetDocument
      include Protocol::Command
      include JSON::Serializable
      # Resulting node.
      getter root : Node
    end

    # Returns the root DOM node (and optionally the subtree) to the caller.
    # Deprecated, as it is not designed to work well with the rest of the DOM agent.
    # Use DOMSnapshot.captureSnapshot instead.
    struct GetFlattenedDocument
      include Protocol::Command
      include JSON::Serializable
      # Resulting node.
      getter nodes : Array(Node)
    end

    # Finds nodes with a given computed style in a subtree.
    struct GetNodesForSubtreeByStyle
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "nodeIds")]
      # Resulting nodes.
      getter node_ids : Array(NodeId)
    end

    # Returns node id at given location. Depending on whether DOM domain is enabled, nodeId is
    # either returned or not.
    struct GetNodeForLocation
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "backendNodeId")]
      # Resulting node.
      getter backend_node_id : BackendNodeId
      @[JSON::Field(key: "frameId")]
      # Frame this node belongs to.
      getter frame_id : Page::FrameId
      @[JSON::Field(key: "nodeId")]
      # Id of the node at given coordinates, only when enabled and requested document.
      getter node_id : NodeId?
    end

    # Returns node's HTML markup.
    struct GetOuterHTML
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "outerHTML")]
      # Outer HTML markup.
      getter outer_html : String
    end

    # Returns the id of the nearest ancestor that is a relayout boundary.
    struct GetRelayoutBoundary
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "nodeId")]
      # Relayout boundary node id for the given node.
      getter node_id : NodeId
    end

    # Returns search results from given `fromIndex` to given `toIndex` from the search with the given
    # identifier.
    struct GetSearchResults
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "nodeIds")]
      # Ids of the search result nodes.
      getter node_ids : Array(NodeId)
    end

    # Hides any highlight.
    struct HideHighlight
      include Protocol::Command
      include JSON::Serializable
    end

    # Highlights DOM node.
    struct HighlightNode
      include Protocol::Command
      include JSON::Serializable
    end

    # Highlights given rectangle.
    struct HighlightRect
      include Protocol::Command
      include JSON::Serializable
    end

    # Marks last undoable state.
    struct MarkUndoableState
      include Protocol::Command
      include JSON::Serializable
    end

    # Moves node into the new container, places it before the given anchor.
    struct MoveTo
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "nodeId")]
      # New id of the moved node.
      getter node_id : NodeId
    end

    # Searches for a given string in the DOM tree. Use `getSearchResults` to access search results or
    # `cancelSearch` to end this search session.
    struct PerformSearch
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "searchId")]
      # Unique search session identifier.
      getter search_id : String
      @[JSON::Field(key: "resultCount")]
      # Number of search results.
      getter result_count : Int::Primitive
    end

    # Requests that the node is sent to the caller given its path. // FIXME, use XPath
    struct PushNodeByPathToFrontend
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "nodeId")]
      # Id of the node for given path.
      getter node_id : NodeId
    end

    # Requests that a batch of nodes is sent to the caller given their backend node ids.
    struct PushNodesByBackendIdsToFrontend
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "nodeIds")]
      # The array of ids of pushed nodes that correspond to the backend ids specified in
      # backendNodeIds.
      getter node_ids : Array(NodeId)
    end

    # Executes `querySelector` on a given node.
    struct QuerySelector
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "nodeId")]
      # Query selector result.
      getter node_id : NodeId
    end

    # Executes `querySelectorAll` on a given node.
    struct QuerySelectorAll
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "nodeIds")]
      # Query selector result.
      getter node_ids : Array(NodeId)
    end

    # Returns NodeIds of current top layer elements.
    # Top layer is rendered closest to the user within a viewport, therefore its elements always
    # appear on top of all other content.
    struct GetTopLayerElements
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "nodeIds")]
      # NodeIds of top layer elements
      getter node_ids : Array(NodeId)
    end

    # Re-does the last undone action.
    struct Redo
      include Protocol::Command
      include JSON::Serializable
    end

    # Removes attribute with given name from an element with given id.
    struct RemoveAttribute
      include Protocol::Command
      include JSON::Serializable
    end

    # Removes node with given id.
    struct RemoveNode
      include Protocol::Command
      include JSON::Serializable
    end

    # Requests that children of the node with given id are returned to the caller in form of
    # `setChildNodes` events where not only immediate children are retrieved, but all children down to
    # the specified depth.
    struct RequestChildNodes
      include Protocol::Command
      include JSON::Serializable
    end

    # Requests that the node is sent to the caller given the JavaScript node object reference. All
    # nodes that form the path from the node to the root are also sent to the client as a series of
    # `setChildNodes` notifications.
    struct RequestNode
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "nodeId")]
      # Node id for given object.
      getter node_id : NodeId
    end

    # Resolves the JavaScript node object for a given NodeId or BackendNodeId.
    struct ResolveNode
      include Protocol::Command
      include JSON::Serializable
      # JavaScript object wrapper for given node.
      getter object : Runtime::RemoteObject
    end

    # Sets attribute for an element with given id.
    struct SetAttributeValue
      include Protocol::Command
      include JSON::Serializable
    end

    # Sets attributes on element with given id. This method is useful when user edits some existing
    # attribute value and types in several attribute name/value pairs.
    struct SetAttributesAsText
      include Protocol::Command
      include JSON::Serializable
    end

    # Sets files for the given file input element.
    struct SetFileInputFiles
      include Protocol::Command
      include JSON::Serializable
    end

    # Sets if stack traces should be captured for Nodes. See `Node.getNodeStackTraces`. Default is disabled.
    struct SetNodeStackTracesEnabled
      include Protocol::Command
      include JSON::Serializable
    end

    # Gets stack traces associated with a Node. As of now, only provides stack trace for Node creation.
    struct GetNodeStackTraces
      include Protocol::Command
      include JSON::Serializable
      # Creation stack trace, if available.
      getter creation : Runtime::StackTrace?
    end

    # Returns file information for the given
    # File wrapper.
    struct GetFileInfo
      include Protocol::Command
      include JSON::Serializable
      getter path : String
    end

    # Enables console to refer to the node with given id via $x (see Command Line API for more details
    # $x functions).
    struct SetInspectedNode
      include Protocol::Command
      include JSON::Serializable
    end

    # Sets node name for a node with given id.
    struct SetNodeName
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "nodeId")]
      # New node's id.
      getter node_id : NodeId
    end

    # Sets node value for a node with given id.
    struct SetNodeValue
      include Protocol::Command
      include JSON::Serializable
    end

    # Sets node HTML markup, returns new node id.
    struct SetOuterHTML
      include Protocol::Command
      include JSON::Serializable
    end

    # Undoes the last performed action.
    struct Undo
      include Protocol::Command
      include JSON::Serializable
    end

    # Returns iframe node that owns iframe with the given domain.
    struct GetFrameOwner
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "backendNodeId")]
      # Resulting node.
      getter backend_node_id : BackendNodeId
      @[JSON::Field(key: "nodeId")]
      # Id of the node at given coordinates, only when enabled and requested document.
      getter node_id : NodeId?
    end

    # Returns the container of the given node based on container query conditions.
    # If containerName is given, it will find the nearest container with a matching name;
    # otherwise it will find the nearest container regardless of its container name.
    struct GetContainerForNode
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "nodeId")]
      # The container node for the given node, or null if not found.
      getter node_id : NodeId?
    end

    # Returns the descendants of a container query container that have
    # container queries against this container.
    struct GetQueryingDescendantsForContainer
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "nodeIds")]
      # Descendant nodes with container queries against the given container.
      getter node_ids : Array(NodeId)
    end

    # ----------------------------------------
    # DOM Section: events
    # ----------------------------------------

    # Fired when `Element`'s attribute is modified.
    struct AttributeModified
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "nodeId")]
      # Id of the node that has changed.
      getter node_id : NodeId
      # Attribute name.
      getter name : String
      # Attribute value.
      getter value : String
    end

    # Fired when `Element`'s attribute is removed.
    struct AttributeRemoved
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "nodeId")]
      # Id of the node that has changed.
      getter node_id : NodeId
      # A ttribute name.
      getter name : String
    end

    # Mirrors `DOMCharacterDataModified` event.
    struct CharacterDataModified
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "nodeId")]
      # Id of the node that has changed.
      getter node_id : NodeId
      @[JSON::Field(key: "characterData")]
      # New text value.
      getter character_data : String
    end

    # Fired when `Container`'s child node count has changed.
    struct ChildNodeCountUpdated
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "nodeId")]
      # Id of the node that has changed.
      getter node_id : NodeId
      @[JSON::Field(key: "childNodeCount")]
      # New node count.
      getter child_node_count : Int::Primitive
    end

    # Mirrors `DOMNodeInserted` event.
    struct ChildNodeInserted
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "parentNodeId")]
      # Id of the node that has changed.
      getter parent_node_id : NodeId
      @[JSON::Field(key: "previousNodeId")]
      # Id of the previous sibling.
      getter previous_node_id : NodeId
      # Inserted node data.
      getter node : Node
    end

    # Mirrors `DOMNodeRemoved` event.
    struct ChildNodeRemoved
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "parentNodeId")]
      # Parent id.
      getter parent_node_id : NodeId
      @[JSON::Field(key: "nodeId")]
      # Id of the node that has been removed.
      getter node_id : NodeId
    end

    # Called when distribution is changed.
    struct DistributedNodesUpdated
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "insertionPointId")]
      # Insertion point where distributed nodes were updated.
      getter insertion_point_id : NodeId
      @[JSON::Field(key: "distributedNodes")]
      # Distributed nodes for given insertion point.
      getter distributed_nodes : Array(BackendNode)
    end

    # Fired when `Document` has been totally updated. Node ids are no longer valid.
    struct DocumentUpdated
      include JSON::Serializable
      include Protocol::Event
    end

    # Fired when `Element`'s inline style is modified via a CSS property modification.
    struct InlineStyleInvalidated
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "nodeIds")]
      # Ids of the nodes for which the inline styles have been invalidated.
      getter node_ids : Array(NodeId)
    end

    # Called when a pseudo element is added to an element.
    struct PseudoElementAdded
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "parentId")]
      # Pseudo element's parent element id.
      getter parent_id : NodeId
      @[JSON::Field(key: "pseudoElement")]
      # The added pseudo element.
      getter pseudo_element : Node
    end

    # Called when top layer elements are changed.
    struct TopLayerElementsUpdated
      include JSON::Serializable
      include Protocol::Event
    end

    # Called when a pseudo element is removed from an element.
    struct PseudoElementRemoved
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "parentId")]
      # Pseudo element's parent element id.
      getter parent_id : NodeId
      @[JSON::Field(key: "pseudoElementId")]
      # The removed pseudo element id.
      getter pseudo_element_id : NodeId
    end

    # Fired when backend wants to provide client with the missing DOM structure. This happens upon
    # most of the calls requesting node ids.
    struct SetChildNodes
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "parentId")]
      # Parent node id to populate with children.
      getter parent_id : NodeId
      # Child nodes array.
      getter nodes : Array(Node)
    end

    # Called when shadow root is popped from the element.
    struct ShadowRootPopped
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "hostId")]
      # Host element id.
      getter host_id : NodeId
      @[JSON::Field(key: "rootId")]
      # Shadow root id.
      getter root_id : NodeId
    end

    # Called when shadow root is pushed into the element.
    struct ShadowRootPushed
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "hostId")]
      # Host element id.
      getter host_id : NodeId
      # Shadow root.
      getter root : Node
    end
  end
end
