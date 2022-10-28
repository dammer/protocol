# Accessibility module dependencies
require "./dom"

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module Accessibility
    # ----------------------------------------
    # Accessibility Section: types
    # ----------------------------------------

    # Unique accessibility node identifier.
    alias AXNodeId = String

    # Enum of possible property types.
    enum AXValueType
      Boolean            # boolean
      Tristate           # tristate
      BooleanOrUndefined # booleanOrUndefined
      Idref              # idref
      IdrefList          # idrefList
      Integer            # integer
      Node               # node
      NodeList           # nodeList
      Number             # number
      String             # string
      ComputedString     # computedString
      Token              # token
      TokenList          # tokenList
      DomRelation        # domRelation
      Role               # role
      InternalRole       # internalRole
      ValueUndefined     # valueUndefined
    end

    # Enum of possible property sources.
    enum AXValueSourceType
      Attribute      # attribute
      Implicit       # implicit
      Style          # style
      Contents       # contents
      Placeholder    # placeholder
      RelatedElement # relatedElement
    end

    # Enum of possible native property sources (as a subtype of a particular AXValueSourceType).
    enum AXValueNativeSourceType
      Description    # description
      Figcaption     # figcaption
      Label          # label
      Labelfor       # labelfor
      Labelwrapped   # labelwrapped
      Legend         # legend
      Rubyannotation # rubyannotation
      Tablecaption   # tablecaption
      Title          # title
      Other          # other
    end

    # A single source for a computed AX property.
    struct AXValueSource
      include JSON::Serializable
      # What type of source this is.
      getter type : AXValueSourceType
      # The value of this property source.
      getter value : AXValue?
      # The name of the relevant attribute, if any.
      getter attribute : String?
      @[JSON::Field(key: "attributeValue")]
      # The value of the relevant attribute, if any.
      getter attribute_value : AXValue?
      # Whether this source is superseded by a higher priority source.
      getter superseded : Bool?
      @[JSON::Field(key: "nativeSource")]
      # The native markup source for this value, e.g. a <label> element.
      getter native_source : AXValueNativeSourceType?
      @[JSON::Field(key: "nativeSourceValue")]
      # The value, such as a node or node list, of the native source.
      getter native_source_value : AXValue?
      # Whether the value for this property is invalid.
      getter invalid : Bool?
      @[JSON::Field(key: "invalidReason")]
      # Reason for the value being invalid, if it is.
      getter invalid_reason : String?
    end

    struct AXRelatedNode
      include JSON::Serializable
      @[JSON::Field(key: "backendDOMNodeId")]
      # The BackendNodeId of the related DOM node.
      getter backend_dom_node_id : DOM::BackendNodeId
      # The IDRef value provided, if any.
      getter idref : String?
      # The text alternative of this node in the current context.
      getter text : String?
    end

    struct AXProperty
      include JSON::Serializable
      # The name of this property.
      getter name : AXPropertyName
      # The value of this property.
      getter value : AXValue
    end

    # A single computed AX property.
    struct AXValue
      include JSON::Serializable
      # The type of this value.
      getter type : AXValueType
      # The computed value of this property.
      getter value : JSON::Any?
      @[JSON::Field(key: "relatedNodes")]
      # One or more related nodes, if applicable.
      getter related_nodes : Array(AXRelatedNode)?
      # The sources which contributed to the computation of this property.
      getter sources : Array(AXValueSource)?
    end

    # Values of AXProperty name:
    # - from 'busy' to 'roledescription': states which apply to every AX node
    # - from 'live' to 'root': attributes which apply to nodes in live regions
    # - from 'autocomplete' to 'valuetext': attributes which apply to widgets
    # - from 'checked' to 'selected': states which apply to widgets
    # - from 'activedescendant' to 'owns' - relationships between elements other than parent/child/sibling.
    enum AXPropertyName
      Busy             # busy
      Disabled         # disabled
      Editable         # editable
      Focusable        # focusable
      Focused          # focused
      Hidden           # hidden
      HiddenRoot       # hiddenRoot
      Invalid          # invalid
      Keyshortcuts     # keyshortcuts
      Settable         # settable
      Roledescription  # roledescription
      Live             # live
      Atomic           # atomic
      Relevant         # relevant
      Root             # root
      Autocomplete     # autocomplete
      HasPopup         # hasPopup
      Level            # level
      Multiselectable  # multiselectable
      Orientation      # orientation
      Multiline        # multiline
      Readonly         # readonly
      Required         # required
      Valuemin         # valuemin
      Valuemax         # valuemax
      Valuetext        # valuetext
      Checked          # checked
      Expanded         # expanded
      Modal            # modal
      Pressed          # pressed
      Selected         # selected
      Activedescendant # activedescendant
      Controls         # controls
      Describedby      # describedby
      Details          # details
      Errormessage     # errormessage
      Flowto           # flowto
      Labelledby       # labelledby
      Owns             # owns
    end

    # A node in the accessibility tree.
    struct AXNode
      include JSON::Serializable
      @[JSON::Field(key: "nodeId")]
      # Unique identifier for this node.
      getter node_id : AXNodeId
      # Whether this node is ignored for accessibility
      getter ignored : Bool
      @[JSON::Field(key: "ignoredReasons")]
      # Collection of reasons why this node is hidden.
      getter ignored_reasons : Array(AXProperty)?
      # This `Node`'s role, whether explicit or implicit.
      getter role : AXValue?
      @[JSON::Field(key: "chromeRole")]
      # This `Node`'s Chrome raw role.
      getter chrome_role : AXValue?
      # The accessible name for this `Node`.
      getter name : AXValue?
      # The accessible description for this `Node`.
      getter description : AXValue?
      # The value for this `Node`.
      getter value : AXValue?
      # All other properties
      getter properties : Array(AXProperty)?
      @[JSON::Field(key: "parentId")]
      # ID for this node's parent.
      getter parent_id : AXNodeId?
      @[JSON::Field(key: "childIds")]
      # IDs for each of this node's child nodes.
      getter child_ids : Array(AXNodeId)?
      @[JSON::Field(key: "backendDOMNodeId")]
      # The backend ID for the associated DOM node, if any.
      getter backend_dom_node_id : DOM::BackendNodeId?
      @[JSON::Field(key: "frameId")]
      # The frame ID for the frame associated with this nodes document.
      getter frame_id : Page::FrameId?
    end

    # ----------------------------------------
    # Accessibility Section: commands
    # ----------------------------------------

    # Disables the accessibility domain.
    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    # Enables the accessibility domain which causes `AXNodeId`s to remain consistent between method calls.
    # This turns on accessibility for the page, which can impact performance until accessibility is disabled.
    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    # Fetches the accessibility node and partial accessibility tree for this DOM node, if it exists.
    struct GetPartialAXTree
      include Protocol::Command
      include JSON::Serializable
      # The `Accessibility.AXNode` for this DOM node, if it exists, plus its ancestors, siblings and
      # children, if requested.
      getter nodes : Array(AXNode)
    end

    # Fetches the entire accessibility tree for the root Document
    struct GetFullAXTree
      include Protocol::Command
      include JSON::Serializable
      getter nodes : Array(AXNode)
    end

    # Fetches the root node.
    # Requires `enable()` to have been called previously.
    struct GetRootAXNode
      include Protocol::Command
      include JSON::Serializable
      getter node : AXNode
    end

    # Fetches a node and all ancestors up to and including the root.
    # Requires `enable()` to have been called previously.
    struct GetAXNodeAndAncestors
      include Protocol::Command
      include JSON::Serializable
      getter nodes : Array(AXNode)
    end

    # Fetches a particular accessibility node by AXNodeId.
    # Requires `enable()` to have been called previously.
    struct GetChildAXNodes
      include Protocol::Command
      include JSON::Serializable
      getter nodes : Array(AXNode)
    end

    # Query a DOM node's accessibility subtree for accessible name and role.
    # This command computes the name and role for all nodes in the subtree, including those that are
    # ignored for accessibility, and returns those that mactch the specified name and role. If no DOM
    # node is specified, or the DOM node does not exist, the command returns an error. If neither
    # `accessibleName` or `role` is specified, it returns all the accessibility nodes in the subtree.
    struct QueryAXTree
      include Protocol::Command
      include JSON::Serializable
      # A list of `Accessibility.AXNode` matching the specified attributes,
      # including nodes that are ignored for accessibility.
      getter nodes : Array(AXNode)
    end

    # ----------------------------------------
    # Accessibility Section: events
    # ----------------------------------------

    # The loadComplete event mirrors the load complete event sent by the browser to assistive
    # technology when the web page has finished loading.
    struct LoadComplete
      include JSON::Serializable
      include Protocol::Event
      # New document root node.
      getter root : AXNode
    end

    # The nodesUpdated event is sent every time a previously requested node has changed the in tree.
    struct NodesUpdated
      include JSON::Serializable
      include Protocol::Event
      # Updated node data.
      getter nodes : Array(AXNode)
    end
  end
end
