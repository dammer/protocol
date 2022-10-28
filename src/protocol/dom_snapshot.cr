# ================================================================================
# This domain facilitates obtaining document snapshots with DOM, layout, and style information.
# ================================================================================

# DOMSnapshot module dependencies
require "./css"
require "./dom"
require "./dom_debugger"
require "./page"

# common Command module
require "./command"

module Protocol
  module DOMSnapshot
    # ----------------------------------------
    # DOMSnapshot Section: types
    # ----------------------------------------

    # A Node in the DOM tree.
    struct DOMNode
      include JSON::Serializable
      @[JSON::Field(key: "nodeType")]
      # `Node`'s nodeType.
      getter node_type : Int::Primitive
      @[JSON::Field(key: "nodeName")]
      # `Node`'s nodeName.
      getter node_name : String
      @[JSON::Field(key: "nodeValue")]
      # `Node`'s nodeValue.
      getter node_value : String
      @[JSON::Field(key: "textValue")]
      # Only set for textarea elements, contains the text value.
      getter text_value : String?
      @[JSON::Field(key: "inputValue")]
      # Only set for input elements, contains the input's associated text value.
      getter input_value : String?
      @[JSON::Field(key: "inputChecked")]
      # Only set for radio and checkbox input elements, indicates if the element has been checked
      getter input_checked : Bool?
      @[JSON::Field(key: "optionSelected")]
      # Only set for option elements, indicates if the element has been selected
      getter option_selected : Bool?
      @[JSON::Field(key: "backendNodeId")]
      # `Node`'s id, corresponds to DOM.Node.backendNodeId.
      getter backend_node_id : DOM::BackendNodeId
      @[JSON::Field(key: "childNodeIndexes")]
      # The indexes of the node's child nodes in the `domNodes` array returned by `getSnapshot`, if
      # any.
      getter child_node_indexes : Array(Int::Primitive)?
      # Attributes of an `Element` node.
      getter attributes : Array(NameValue)?
      @[JSON::Field(key: "pseudoElementIndexes")]
      # Indexes of pseudo elements associated with this node in the `domNodes` array returned by
      # `getSnapshot`, if any.
      getter pseudo_element_indexes : Array(Int::Primitive)?
      @[JSON::Field(key: "layoutNodeIndex")]
      # The index of the node's related layout tree node in the `layoutTreeNodes` array returned by
      # `getSnapshot`, if any.
      getter layout_node_index : Int::Primitive?
      @[JSON::Field(key: "documentURL")]
      # Document URL that `Document` or `FrameOwner` node points to.
      getter document_url : String?
      @[JSON::Field(key: "baseURL")]
      # Base URL that `Document` or `FrameOwner` node uses for URL completion.
      getter base_url : String?
      @[JSON::Field(key: "contentLanguage")]
      # Only set for documents, contains the document's content language.
      getter content_language : String?
      @[JSON::Field(key: "documentEncoding")]
      # Only set for documents, contains the document's character set encoding.
      getter document_encoding : String?
      @[JSON::Field(key: "publicId")]
      # `DocumentType` node's publicId.
      getter public_id : String?
      @[JSON::Field(key: "systemId")]
      # `DocumentType` node's systemId.
      getter system_id : String?
      @[JSON::Field(key: "frameId")]
      # Frame ID for frame owner elements and also for the document node.
      getter frame_id : Page::FrameId?
      @[JSON::Field(key: "contentDocumentIndex")]
      # The index of a frame owner element's content document in the `domNodes` array returned by
      # `getSnapshot`, if any.
      getter content_document_index : Int::Primitive?
      @[JSON::Field(key: "pseudoType")]
      # Type of a pseudo element node.
      getter pseudo_type : DOM::PseudoType?
      @[JSON::Field(key: "shadowRootType")]
      # Shadow root type.
      getter shadow_root_type : DOM::ShadowRootType?
      @[JSON::Field(key: "isClickable")]
      # Whether this DOM node responds to mouse clicks. This includes nodes that have had click
      # event listeners attached via JavaScript as well as anchor tags that naturally navigate when
      # clicked.
      getter is_clickable : Bool?
      @[JSON::Field(key: "eventListeners")]
      # Details of the node's event listeners, if any.
      getter event_listeners : Array(DOMDebugger::EventListener)?
      @[JSON::Field(key: "currentSourceURL")]
      # The selected url for nodes with a srcset attribute.
      getter current_source_url : String?
      @[JSON::Field(key: "originURL")]
      # The url of the script (if any) that generates this node.
      getter origin_url : String?
      @[JSON::Field(key: "scrollOffsetX")]
      # Scroll offsets, set when this node is a Document.
      getter scroll_offset_x : Number::Primitive?
      @[JSON::Field(key: "scrollOffsetY")]
      getter scroll_offset_y : Number::Primitive?
    end

    # Details of post layout rendered text positions. The exact layout should not be regarded as
    # stable and may change between versions.
    struct InlineTextBox
      include JSON::Serializable
      @[JSON::Field(key: "boundingBox")]
      # The bounding box in document coordinates. Note that scroll offset of the document is ignored.
      getter bounding_box : DOM::Rect
      @[JSON::Field(key: "startCharacterIndex")]
      # The starting index in characters, for this post layout textbox substring. Characters that
      # would be represented as a surrogate pair in UTF-16 have length 2.
      getter start_character_index : Int::Primitive
      @[JSON::Field(key: "numCharacters")]
      # The number of characters in this post layout textbox substring. Characters that would be
      # represented as a surrogate pair in UTF-16 have length 2.
      getter num_characters : Int::Primitive
    end

    # Details of an element in the DOM tree with a LayoutObject.
    struct LayoutTreeNode
      include JSON::Serializable
      @[JSON::Field(key: "domNodeIndex")]
      # The index of the related DOM node in the `domNodes` array returned by `getSnapshot`.
      getter dom_node_index : Int::Primitive
      @[JSON::Field(key: "boundingBox")]
      # The bounding box in document coordinates. Note that scroll offset of the document is ignored.
      getter bounding_box : DOM::Rect
      @[JSON::Field(key: "layoutText")]
      # Contents of the LayoutText, if any.
      getter layout_text : String?
      @[JSON::Field(key: "inlineTextNodes")]
      # The post-layout inline text nodes, if any.
      getter inline_text_nodes : Array(InlineTextBox)?
      @[JSON::Field(key: "styleIndex")]
      # Index into the `computedStyles` array returned by `getSnapshot`.
      getter style_index : Int::Primitive?
      @[JSON::Field(key: "paintOrder")]
      # Global paint order index, which is determined by the stacking order of the nodes. Nodes
      # that are painted together will have the same index. Only provided if includePaintOrder in
      # getSnapshot was true.
      getter paint_order : Int::Primitive?
      @[JSON::Field(key: "isStackingContext")]
      # Set to true to indicate the element begins a new stacking context.
      getter is_stacking_context : Bool?
    end

    # A subset of the full ComputedStyle as defined by the request whitelist.
    struct ComputedStyle
      include JSON::Serializable
      # Name/value pairs of computed style properties.
      getter properties : Array(NameValue)
    end

    # A name/value pair.
    struct NameValue
      include JSON::Serializable
      # Attribute/property name.
      getter name : String
      # Attribute/property value.
      getter value : String
    end

    # Index of the string in the strings table.
    alias StringIndex = Int::Primitive

    # Index of the string in the strings table.
    alias ArrayOfStrings = Array(StringIndex)

    # Data that is only present on rare nodes.
    struct RareStringData
      include JSON::Serializable
      getter index : Array(Int::Primitive)
      getter value : Array(StringIndex)
    end

    struct RareBooleanData
      include JSON::Serializable
      getter index : Array(Int::Primitive)
    end

    struct RareIntegerData
      include JSON::Serializable
      getter index : Array(Int::Primitive)
      getter value : Array(Int::Primitive)
    end

    alias Rectangle = Array(Number::Primitive)

    # Document snapshot.
    struct DocumentSnapshot
      include JSON::Serializable
      @[JSON::Field(key: "documentURL")]
      # Document URL that `Document` or `FrameOwner` node points to.
      getter document_url : StringIndex
      # Document title.
      getter title : StringIndex
      @[JSON::Field(key: "baseURL")]
      # Base URL that `Document` or `FrameOwner` node uses for URL completion.
      getter base_url : StringIndex
      @[JSON::Field(key: "contentLanguage")]
      # Contains the document's content language.
      getter content_language : StringIndex
      @[JSON::Field(key: "encodingName")]
      # Contains the document's character set encoding.
      getter encoding_name : StringIndex
      @[JSON::Field(key: "publicId")]
      # `DocumentType` node's publicId.
      getter public_id : StringIndex
      @[JSON::Field(key: "systemId")]
      # `DocumentType` node's systemId.
      getter system_id : StringIndex
      @[JSON::Field(key: "frameId")]
      # Frame ID for frame owner elements and also for the document node.
      getter frame_id : StringIndex
      # A table with dom nodes.
      getter nodes : NodeTreeSnapshot
      # The nodes in the layout tree.
      getter layout : LayoutTreeSnapshot
      @[JSON::Field(key: "textBoxes")]
      # The post-layout inline text nodes.
      getter text_boxes : TextBoxSnapshot
      @[JSON::Field(key: "scrollOffsetX")]
      # Horizontal scroll offset.
      getter scroll_offset_x : Number::Primitive?
      @[JSON::Field(key: "scrollOffsetY")]
      # Vertical scroll offset.
      getter scroll_offset_y : Number::Primitive?
      @[JSON::Field(key: "contentWidth")]
      # Document content width.
      getter content_width : Number::Primitive?
      @[JSON::Field(key: "contentHeight")]
      # Document content height.
      getter content_height : Number::Primitive?
    end

    # Table containing nodes.
    struct NodeTreeSnapshot
      include JSON::Serializable
      @[JSON::Field(key: "parentIndex")]
      # Parent node index.
      getter parent_index : Array(Int::Primitive)?
      @[JSON::Field(key: "nodeType")]
      # `Node`'s nodeType.
      getter node_type : Array(Int::Primitive)?
      @[JSON::Field(key: "shadowRootType")]
      # Type of the shadow root the `Node` is in. String values are equal to the `ShadowRootType` enum.
      getter shadow_root_type : RareStringData?
      @[JSON::Field(key: "nodeName")]
      # `Node`'s nodeName.
      getter node_name : Array(StringIndex)?
      @[JSON::Field(key: "nodeValue")]
      # `Node`'s nodeValue.
      getter node_value : Array(StringIndex)?
      @[JSON::Field(key: "backendNodeId")]
      # `Node`'s id, corresponds to DOM.Node.backendNodeId.
      getter backend_node_id : Array(DOM::BackendNodeId)?
      # Attributes of an `Element` node. Flatten name, value pairs.
      getter attributes : Array(ArrayOfStrings)?
      @[JSON::Field(key: "textValue")]
      # Only set for textarea elements, contains the text value.
      getter text_value : RareStringData?
      @[JSON::Field(key: "inputValue")]
      # Only set for input elements, contains the input's associated text value.
      getter input_value : RareStringData?
      @[JSON::Field(key: "inputChecked")]
      # Only set for radio and checkbox input elements, indicates if the element has been checked
      getter input_checked : RareBooleanData?
      @[JSON::Field(key: "optionSelected")]
      # Only set for option elements, indicates if the element has been selected
      getter option_selected : RareBooleanData?
      @[JSON::Field(key: "contentDocumentIndex")]
      # The index of the document in the list of the snapshot documents.
      getter content_document_index : RareIntegerData?
      @[JSON::Field(key: "pseudoType")]
      # Type of a pseudo element node.
      getter pseudo_type : RareStringData?
      @[JSON::Field(key: "pseudoIdentifier")]
      # Pseudo element identifier for this node. Only present if there is a
      # valid pseudoType.
      getter pseudo_identifier : RareStringData?
      @[JSON::Field(key: "isClickable")]
      # Whether this DOM node responds to mouse clicks. This includes nodes that have had click
      # event listeners attached via JavaScript as well as anchor tags that naturally navigate when
      # clicked.
      getter is_clickable : RareBooleanData?
      @[JSON::Field(key: "currentSourceURL")]
      # The selected url for nodes with a srcset attribute.
      getter current_source_url : RareStringData?
      @[JSON::Field(key: "originURL")]
      # The url of the script (if any) that generates this node.
      getter origin_url : RareStringData?
    end

    # Table of details of an element in the DOM tree with a LayoutObject.
    struct LayoutTreeSnapshot
      include JSON::Serializable
      @[JSON::Field(key: "nodeIndex")]
      # Index of the corresponding node in the `NodeTreeSnapshot` array returned by `captureSnapshot`.
      getter node_index : Array(Int::Primitive)
      # Array of indexes specifying computed style strings, filtered according to the `computedStyles` parameter passed to `captureSnapshot`.
      getter styles : Array(ArrayOfStrings)
      # The absolute position bounding box.
      getter bounds : Array(Rectangle)
      # Contents of the LayoutText, if any.
      getter text : Array(StringIndex)
      @[JSON::Field(key: "stackingContexts")]
      # Stacking context information.
      getter stacking_contexts : RareBooleanData
      @[JSON::Field(key: "paintOrders")]
      # Global paint order index, which is determined by the stacking order of the nodes. Nodes
      # that are painted together will have the same index. Only provided if includePaintOrder in
      # captureSnapshot was true.
      getter paint_orders : Array(Int::Primitive)?
      @[JSON::Field(key: "offsetRects")]
      # The offset rect of nodes. Only available when includeDOMRects is set to true
      getter offset_rects : Array(Rectangle)?
      @[JSON::Field(key: "scrollRects")]
      # The scroll rect of nodes. Only available when includeDOMRects is set to true
      getter scroll_rects : Array(Rectangle)?
      @[JSON::Field(key: "clientRects")]
      # The client rect of nodes. Only available when includeDOMRects is set to true
      getter client_rects : Array(Rectangle)?
      @[JSON::Field(key: "blendedBackgroundColors")]
      # The list of background colors that are blended with colors of overlapping elements.
      getter blended_background_colors : Array(StringIndex)?
      @[JSON::Field(key: "textColorOpacities")]
      # The list of computed text opacities.
      getter text_color_opacities : Array(Number::Primitive)?
    end

    # Table of details of the post layout rendered text positions. The exact layout should not be regarded as
    # stable and may change between versions.
    struct TextBoxSnapshot
      include JSON::Serializable
      @[JSON::Field(key: "layoutIndex")]
      # Index of the layout tree node that owns this box collection.
      getter layout_index : Array(Int::Primitive)
      # The absolute position bounding box.
      getter bounds : Array(Rectangle)
      # The starting index in characters, for this post layout textbox substring. Characters that
      # would be represented as a surrogate pair in UTF-16 have length 2.
      getter start : Array(Int::Primitive)
      # The number of characters in this post layout textbox substring. Characters that would be
      # represented as a surrogate pair in UTF-16 have length 2.
      getter length : Array(Int::Primitive)
    end

    # ----------------------------------------
    # DOMSnapshot Section: commands
    # ----------------------------------------

    # Disables DOM snapshot agent for the given page.
    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    # Enables DOM snapshot agent for the given page.
    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    # Returns a document snapshot, including the full DOM tree of the root node (including iframes,
    # template contents, and imported documents) in a flattened array, as well as layout and
    # white-listed computed style information for the nodes. Shadow DOM in the returned DOM tree is
    # flattened.
    struct GetSnapshot
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "domNodes")]
      # The nodes in the DOM tree. The DOMNode at index 0 corresponds to the root document.
      getter dom_nodes : Array(DOMNode)
      @[JSON::Field(key: "layoutTreeNodes")]
      # The nodes in the layout tree.
      getter layout_tree_nodes : Array(LayoutTreeNode)
      @[JSON::Field(key: "computedStyles")]
      # Whitelisted ComputedStyle properties for each node in the layout tree.
      getter computed_styles : Array(ComputedStyle)
    end

    # Returns a document snapshot, including the full DOM tree of the root node (including iframes,
    # template contents, and imported documents) in a flattened array, as well as layout and
    # white-listed computed style information for the nodes. Shadow DOM in the returned DOM tree is
    # flattened.
    struct CaptureSnapshot
      include Protocol::Command
      include JSON::Serializable
      # The nodes in the DOM tree. The DOMNode at index 0 corresponds to the root document.
      getter documents : Array(DocumentSnapshot)
      # Shared string table that all string properties refer to with indexes.
      getter strings : Array(String)
    end
  end
end
