# ================================================================================
# This domain exposes CSS read/write operations. All CSS objects (stylesheets, rules, and styles)
# have an associated `id` used in subsequent operations on the related object. Each object type has
# a specific `id` structure, and those are not interchangeable between objects of different kinds.
# CSS objects can be loaded using the `get*ForNode()` calls (which accept a DOM node id). A client
# can also keep track of stylesheets via the `styleSheetAdded`/`styleSheetRemoved` events and
# subsequently load the required stylesheet contents using the `getStyleSheet[Text]()` methods.
# ================================================================================

# CSS module dependencies
require "./dom"
require "./page"

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module CSS
    # ----------------------------------------
    # CSS Section: types
    # ----------------------------------------

    alias StyleSheetId = String

    # Stylesheet type: "injected" for stylesheets injected via extension, "user-agent" for user-agent
    # stylesheets, "inspector" for stylesheets created by the inspector (i.e. those holding the "via
    # inspector" rules), "regular" for regular stylesheets.
    @[DashEnum]
    enum StyleSheetOrigin
      Injected  # injected
      UserAgent # user-agent
      Inspector # inspector
      Regular   # regular
    end

    # CSS rule collection for a single pseudo style.
    struct PseudoElementMatches
      include JSON::Serializable
      @[JSON::Field(key: "pseudoType")]
      # Pseudo element type.
      getter pseudo_type : DOM::PseudoType
      @[JSON::Field(key: "pseudoIdentifier")]
      # Pseudo element custom ident.
      getter pseudo_identifier : String?
      # Matches of CSS rules applicable to the pseudo style.
      getter matches : Array(RuleMatch)
    end

    # Inherited CSS rule collection from ancestor node.
    struct InheritedStyleEntry
      include JSON::Serializable
      @[JSON::Field(key: "inlineStyle")]
      # The ancestor node's inline style, if any, in the style inheritance chain.
      getter inline_style : CSSStyle?
      @[JSON::Field(key: "matchedCSSRules")]
      # Matches of CSS rules matching the ancestor node in the style inheritance chain.
      getter matched_css_rules : Array(RuleMatch)
    end

    # Inherited pseudo element matches from pseudos of an ancestor node.
    struct InheritedPseudoElementMatches
      include JSON::Serializable
      @[JSON::Field(key: "pseudoElements")]
      # Matches of pseudo styles from the pseudos of an ancestor node.
      getter pseudo_elements : Array(PseudoElementMatches)
    end

    # Match data for a CSS rule.
    struct RuleMatch
      include JSON::Serializable
      # CSS rule in the match.
      getter rule : CSSRule
      @[JSON::Field(key: "matchingSelectors")]
      # Matching selector indices in the rule's selectorList selectors (0-based).
      getter matching_selectors : Array(Int::Primitive)
    end

    # Data for a simple selector (these are delimited by commas in a selector list).
    struct Value
      include JSON::Serializable
      # Value text.
      getter text : String
      # Value range in the underlying resource (if available).
      getter range : SourceRange?
    end

    # Selector list data.
    struct SelectorList
      include JSON::Serializable
      # Selectors in the list.
      getter selectors : Array(Value)
      # Rule selector text.
      getter text : String
    end

    # CSS stylesheet metainformation.
    struct CSSStyleSheetHeader
      include JSON::Serializable
      @[JSON::Field(key: "styleSheetId")]
      # The stylesheet identifier.
      getter style_sheet_id : StyleSheetId
      @[JSON::Field(key: "frameId")]
      # Owner frame identifier.
      getter frame_id : Page::FrameId
      @[JSON::Field(key: "sourceURL")]
      # Stylesheet resource URL. Empty if this is a constructed stylesheet created using
      # new CSSStyleSheet() (but non-empty if this is a constructed sylesheet imported
      # as a CSS module script).
      getter source_url : String
      @[JSON::Field(key: "sourceMapURL")]
      # URL of source map associated with the stylesheet (if any).
      getter source_map_url : String?
      # Stylesheet origin.
      getter origin : StyleSheetOrigin
      # Stylesheet title.
      getter title : String
      @[JSON::Field(key: "ownerNode")]
      # The backend id for the owner node of the stylesheet.
      getter owner_node : DOM::BackendNodeId?
      # Denotes whether the stylesheet is disabled.
      getter disabled : Bool
      @[JSON::Field(key: "hasSourceURL")]
      # Whether the sourceURL field value comes from the sourceURL comment.
      getter has_source_url : Bool?
      @[JSON::Field(key: "isInline")]
      # Whether this stylesheet is created for STYLE tag by parser. This flag is not set for
      # document.written STYLE tags.
      getter is_inline : Bool
      @[JSON::Field(key: "isMutable")]
      # Whether this stylesheet is mutable. Inline stylesheets become mutable
      # after they have been modified via CSSOM API.
      # <link> element's stylesheets become mutable only if DevTools modifies them.
      # Constructed stylesheets (new CSSStyleSheet()) are mutable immediately after creation.
      getter is_mutable : Bool
      @[JSON::Field(key: "isConstructed")]
      # True if this stylesheet is created through new CSSStyleSheet() or imported as a
      # CSS module script.
      getter is_constructed : Bool
      @[JSON::Field(key: "startLine")]
      # Line offset of the stylesheet within the resource (zero based).
      getter start_line : Number::Primitive
      @[JSON::Field(key: "startColumn")]
      # Column offset of the stylesheet within the resource (zero based).
      getter start_column : Number::Primitive
      # Size of the content (in characters).
      getter length : Number::Primitive
      @[JSON::Field(key: "endLine")]
      # Line offset of the end of the stylesheet within the resource (zero based).
      getter end_line : Number::Primitive
      @[JSON::Field(key: "endColumn")]
      # Column offset of the end of the stylesheet within the resource (zero based).
      getter end_column : Number::Primitive
    end

    # CSS rule representation.
    struct CSSRule
      include JSON::Serializable
      @[JSON::Field(key: "styleSheetId")]
      # The css style sheet identifier (absent for user agent stylesheet and user-specified
      # stylesheet rules) this rule came from.
      getter style_sheet_id : StyleSheetId?
      @[JSON::Field(key: "selectorList")]
      # Rule selector data.
      getter selector_list : SelectorList
      # Parent stylesheet's origin.
      getter origin : StyleSheetOrigin
      # Associated style declaration.
      getter style : CSSStyle
      # Media list array (for rules involving media queries). The array enumerates media queries
      # starting with the innermost one, going outwards.
      getter media : Array(CSSMedia)?
      @[JSON::Field(key: "containerQueries")]
      # Container query list array (for rules involving container queries).
      # The array enumerates container queries starting with the innermost one, going outwards.
      getter container_queries : Array(CSSContainerQuery)?
      # @supports CSS at-rule array.
      # The array enumerates @supports at-rules starting with the innermost one, going outwards.
      getter supports : Array(CSSSupports)?
      # Cascade layer array. Contains the layer hierarchy that this rule belongs to starting
      # with the innermost layer and going outwards.
      getter layers : Array(CSSLayer)?
      # @scope CSS at-rule array.
      # The array enumerates @scope at-rules starting with the innermost one, going outwards.
      getter scopes : Array(CSSScope)?
    end

    # CSS coverage information.
    struct RuleUsage
      include JSON::Serializable
      @[JSON::Field(key: "styleSheetId")]
      # The css style sheet identifier (absent for user agent stylesheet and user-specified
      # stylesheet rules) this rule came from.
      getter style_sheet_id : StyleSheetId
      @[JSON::Field(key: "startOffset")]
      # Offset of the start of the rule (including selector) from the beginning of the stylesheet.
      getter start_offset : Number::Primitive
      @[JSON::Field(key: "endOffset")]
      # Offset of the end of the rule body from the beginning of the stylesheet.
      getter end_offset : Number::Primitive
      # Indicates whether the rule was actually used by some element in the page.
      getter used : Bool
    end

    # Text range within a resource. All numbers are zero-based.
    struct SourceRange
      include JSON::Serializable
      @[JSON::Field(key: "startLine")]
      # Start line of range.
      getter start_line : Int::Primitive
      @[JSON::Field(key: "startColumn")]
      # Start column of range (inclusive).
      getter start_column : Int::Primitive
      @[JSON::Field(key: "endLine")]
      # End line of range
      getter end_line : Int::Primitive
      @[JSON::Field(key: "endColumn")]
      # End column of range (exclusive).
      getter end_column : Int::Primitive
    end

    struct ShorthandEntry
      include JSON::Serializable
      # Shorthand name.
      getter name : String
      # Shorthand value.
      getter value : String
      # Whether the property has "!important" annotation (implies `false` if absent).
      getter important : Bool?
    end

    struct CSSComputedStyleProperty
      include JSON::Serializable
      # Computed style property name.
      getter name : String
      # Computed style property value.
      getter value : String
    end

    # CSS style representation.
    struct CSSStyle
      include JSON::Serializable
      @[JSON::Field(key: "styleSheetId")]
      # The css style sheet identifier (absent for user agent stylesheet and user-specified
      # stylesheet rules) this rule came from.
      getter style_sheet_id : StyleSheetId?
      @[JSON::Field(key: "cssProperties")]
      # CSS properties in the style.
      getter css_properties : Array(CSSProperty)
      @[JSON::Field(key: "shorthandEntries")]
      # Computed values for all shorthands found in the style.
      getter shorthand_entries : Array(ShorthandEntry)
      @[JSON::Field(key: "cssText")]
      # Style declaration text (if available).
      getter css_text : String?
      # Style declaration range in the enclosing stylesheet (if available).
      getter range : SourceRange?
    end

    # CSS property declaration data.
    struct CSSProperty
      include JSON::Serializable
      # The property name.
      getter name : String
      # The property value.
      getter value : String
      # Whether the property has "!important" annotation (implies `false` if absent).
      getter important : Bool?
      # Whether the property is implicit (implies `false` if absent).
      getter implicit : Bool?
      # The full property text as specified in the style.
      getter text : String?
      @[JSON::Field(key: "parsedOk")]
      # Whether the property is understood by the browser (implies `true` if absent).
      getter parsed_ok : Bool?
      # Whether the property is disabled by the user (present for source-based properties only).
      getter disabled : Bool?
      # The entire property range in the enclosing style declaration (if available).
      getter range : SourceRange?
      @[JSON::Field(key: "longhandProperties")]
      # Parsed longhand components of this property if it is a shorthand.
      # This field will be empty if the given property is not a shorthand.
      getter longhand_properties : Array(CSSProperty)?
    end

    # CSS media rule descriptor.
    struct CSSMedia
      include JSON::Serializable
      # Media query text.
      getter text : String
      # Source of the media query: "mediaRule" if specified by a @media rule, "importRule" if
      # specified by an @import rule, "linkedSheet" if specified by a "media" attribute in a linked
      # stylesheet's LINK tag, "inlineSheet" if specified by a "media" attribute in an inline
      # stylesheet's STYLE tag.
      getter source : String
      @[JSON::Field(key: "sourceURL")]
      # URL of the document containing the media query description.
      getter source_url : String?
      # The associated rule (@media or @import) header range in the enclosing stylesheet (if
      # available).
      getter range : SourceRange?
      @[JSON::Field(key: "styleSheetId")]
      # Identifier of the stylesheet containing this object (if exists).
      getter style_sheet_id : StyleSheetId?
      @[JSON::Field(key: "mediaList")]
      # Array of media queries.
      getter media_list : Array(MediaQuery)?
    end

    # Media query descriptor.
    struct MediaQuery
      include JSON::Serializable
      # Array of media query expressions.
      getter expressions : Array(MediaQueryExpression)
      # Whether the media query condition is satisfied.
      getter active : Bool
    end

    # Media query expression descriptor.
    struct MediaQueryExpression
      include JSON::Serializable
      # Media query expression value.
      getter value : Number::Primitive
      # Media query expression units.
      getter unit : String
      # Media query expression feature.
      getter feature : String
      @[JSON::Field(key: "valueRange")]
      # The associated range of the value text in the enclosing stylesheet (if available).
      getter value_range : SourceRange?
      @[JSON::Field(key: "computedLength")]
      # Computed length of media query expression (if applicable).
      getter computed_length : Number::Primitive?
    end

    # CSS container query rule descriptor.
    struct CSSContainerQuery
      include JSON::Serializable
      # Container query text.
      getter text : String
      # The associated rule header range in the enclosing stylesheet (if
      # available).
      getter range : SourceRange?
      @[JSON::Field(key: "styleSheetId")]
      # Identifier of the stylesheet containing this object (if exists).
      getter style_sheet_id : StyleSheetId?
      # Optional name for the container.
      getter name : String?
    end

    # CSS Supports at-rule descriptor.
    struct CSSSupports
      include JSON::Serializable
      # Supports rule text.
      getter text : String
      # Whether the supports condition is satisfied.
      getter active : Bool
      # The associated rule header range in the enclosing stylesheet (if
      # available).
      getter range : SourceRange?
      @[JSON::Field(key: "styleSheetId")]
      # Identifier of the stylesheet containing this object (if exists).
      getter style_sheet_id : StyleSheetId?
    end

    # CSS Scope at-rule descriptor.
    struct CSSScope
      include JSON::Serializable
      # Scope rule text.
      getter text : String
      # The associated rule header range in the enclosing stylesheet (if
      # available).
      getter range : SourceRange?
      @[JSON::Field(key: "styleSheetId")]
      # Identifier of the stylesheet containing this object (if exists).
      getter style_sheet_id : StyleSheetId?
    end

    # CSS Layer at-rule descriptor.
    struct CSSLayer
      include JSON::Serializable
      # Layer name.
      getter text : String
      # The associated rule header range in the enclosing stylesheet (if
      # available).
      getter range : SourceRange?
      @[JSON::Field(key: "styleSheetId")]
      # Identifier of the stylesheet containing this object (if exists).
      getter style_sheet_id : StyleSheetId?
    end

    # CSS Layer data.
    struct CSSLayerData
      include JSON::Serializable
      # Layer name.
      getter name : String
      @[JSON::Field(key: "subLayers")]
      # Direct sub-layers
      getter sub_layers : Array(CSSLayerData)?
      # Layer order. The order determines the order of the layer in the cascade order.
      # A higher number has higher priority in the cascade order.
      getter order : Number::Primitive
    end

    # Information about amount of glyphs that were rendered with given font.
    struct PlatformFontUsage
      include JSON::Serializable
      @[JSON::Field(key: "familyName")]
      # Font's family name reported by platform.
      getter family_name : String
      @[JSON::Field(key: "isCustomFont")]
      # Indicates if the font was downloaded or resolved locally.
      getter is_custom_font : Bool
      @[JSON::Field(key: "glyphCount")]
      # Amount of glyphs that were rendered with this font.
      getter glyph_count : Number::Primitive
    end

    # Information about font variation axes for variable fonts
    struct FontVariationAxis
      include JSON::Serializable
      # The font-variation-setting tag (a.k.a. "axis tag").
      getter tag : String
      # Human-readable variation name in the default language (normally, "en").
      getter name : String
      @[JSON::Field(key: "minValue")]
      # The minimum value (inclusive) the font supports for this tag.
      getter min_value : Number::Primitive
      @[JSON::Field(key: "maxValue")]
      # The maximum value (inclusive) the font supports for this tag.
      getter max_value : Number::Primitive
      @[JSON::Field(key: "defaultValue")]
      # The default value.
      getter default_value : Number::Primitive
    end

    # Properties of a web font: https://www.w3.org/TR/2008/REC-CSS2-20080411/fonts.html#font-descriptions
    # and additional information such as platformFontFamily and fontVariationAxes.
    struct FontFace
      include JSON::Serializable
      @[JSON::Field(key: "fontFamily")]
      # The font-family.
      getter font_family : String
      @[JSON::Field(key: "fontStyle")]
      # The font-style.
      getter font_style : String
      @[JSON::Field(key: "fontVariant")]
      # The font-variant.
      getter font_variant : String
      @[JSON::Field(key: "fontWeight")]
      # The font-weight.
      getter font_weight : String
      @[JSON::Field(key: "fontStretch")]
      # The font-stretch.
      getter font_stretch : String
      @[JSON::Field(key: "fontDisplay")]
      # The font-display.
      getter font_display : String
      @[JSON::Field(key: "unicodeRange")]
      # The unicode-range.
      getter unicode_range : String
      # The src.
      getter src : String
      @[JSON::Field(key: "platformFontFamily")]
      # The resolved platform font family
      getter platform_font_family : String
      @[JSON::Field(key: "fontVariationAxes")]
      # Available variation settings (a.k.a. "axes").
      getter font_variation_axes : Array(FontVariationAxis)?
    end

    # CSS keyframes rule representation.
    struct CSSKeyframesRule
      include JSON::Serializable
      @[JSON::Field(key: "animationName")]
      # Animation name.
      getter animation_name : Value
      # List of keyframes.
      getter keyframes : Array(CSSKeyframeRule)
    end

    # CSS keyframe rule representation.
    struct CSSKeyframeRule
      include JSON::Serializable
      @[JSON::Field(key: "styleSheetId")]
      # The css style sheet identifier (absent for user agent stylesheet and user-specified
      # stylesheet rules) this rule came from.
      getter style_sheet_id : StyleSheetId?
      # Parent stylesheet's origin.
      getter origin : StyleSheetOrigin
      @[JSON::Field(key: "keyText")]
      # Associated key text.
      getter key_text : Value
      # Associated style declaration.
      getter style : CSSStyle
    end

    # A descriptor of operation to mutate style declaration text.
    struct StyleDeclarationEdit
      include JSON::Serializable
      @[JSON::Field(key: "styleSheetId")]
      # The css style sheet identifier.
      getter style_sheet_id : StyleSheetId
      # The range of the style text in the enclosing stylesheet.
      getter range : SourceRange
      # New style text.
      getter text : String
    end

    # ----------------------------------------
    # CSS Section: commands
    # ----------------------------------------

    # Inserts a new rule with the given `ruleText` in a stylesheet with given `styleSheetId`, at the
    # position specified by `location`.
    struct AddRule
      include Protocol::Command
      include JSON::Serializable
      # The newly created rule.
      getter rule : CSSRule
    end

    # Returns all class names from specified stylesheet.
    struct CollectClassNames
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "classNames")]
      # Class name list.
      getter class_names : Array(String)
    end

    # Creates a new special "via-inspector" stylesheet in the frame with given `frameId`.
    struct CreateStyleSheet
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "styleSheetId")]
      # Identifier of the created "via-inspector" stylesheet.
      getter style_sheet_id : StyleSheetId
    end

    # Disables the CSS agent for the given page.
    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    # Enables the CSS agent for the given page. Clients should not assume that the CSS agent has been
    # enabled until the result of this command is received.
    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    # Ensures that the given node will have specified pseudo-classes whenever its style is computed by
    # the browser.
    struct ForcePseudoState
      include Protocol::Command
      include JSON::Serializable
    end

    struct GetBackgroundColors
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "backgroundColors")]
      # The range of background colors behind this element, if it contains any visible text. If no
      # visible text is present, this will be undefined. In the case of a flat background color,
      # this will consist of simply that color. In the case of a gradient, this will consist of each
      # of the color stops. For anything more complicated, this will be an empty array. Images will
      # be ignored (as if the image had failed to load).
      getter background_colors : Array(String)?
      @[JSON::Field(key: "computedFontSize")]
      # The computed font size for this node, as a CSS computed value string (e.g. '12px').
      getter computed_font_size : String?
      @[JSON::Field(key: "computedFontWeight")]
      # The computed font weight for this node, as a CSS computed value string (e.g. 'normal' or
      # '100').
      getter computed_font_weight : String?
    end

    # Returns the computed style for a DOM node identified by `nodeId`.
    struct GetComputedStyleForNode
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "computedStyle")]
      # Computed style for the specified DOM node.
      getter computed_style : Array(CSSComputedStyleProperty)
    end

    # Returns the styles defined inline (explicitly in the "style" attribute and implicitly, using DOM
    # attributes) for a DOM node identified by `nodeId`.
    struct GetInlineStylesForNode
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "inlineStyle")]
      # Inline style for the specified DOM node.
      getter inline_style : CSSStyle?
      @[JSON::Field(key: "attributesStyle")]
      # Attribute-defined element style (e.g. resulting from "width=20 height=100%").
      getter attributes_style : CSSStyle?
    end

    # Returns requested styles for a DOM node identified by `nodeId`.
    struct GetMatchedStylesForNode
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "inlineStyle")]
      # Inline style for the specified DOM node.
      getter inline_style : CSSStyle?
      @[JSON::Field(key: "attributesStyle")]
      # Attribute-defined element style (e.g. resulting from "width=20 height=100%").
      getter attributes_style : CSSStyle?
      @[JSON::Field(key: "matchedCSSRules")]
      # CSS rules matching this node, from all applicable stylesheets.
      getter matched_css_rules : Array(RuleMatch)?
      @[JSON::Field(key: "pseudoElements")]
      # Pseudo style matches for this node.
      getter pseudo_elements : Array(PseudoElementMatches)?
      # A chain of inherited styles (from the immediate node parent up to the DOM tree root).
      getter inherited : Array(InheritedStyleEntry)?
      @[JSON::Field(key: "inheritedPseudoElements")]
      # A chain of inherited pseudo element styles (from the immediate node parent up to the DOM tree root).
      getter inherited_pseudo_elements : Array(InheritedPseudoElementMatches)?
      @[JSON::Field(key: "cssKeyframesRules")]
      # A list of CSS keyframed animations matching this node.
      getter css_keyframes_rules : Array(CSSKeyframesRule)?
      @[JSON::Field(key: "parentLayoutNodeId")]
      # Id of the first parent element that does not have display: contents.
      getter parent_layout_node_id : DOM::NodeId?
    end

    # Returns all media queries parsed by the rendering engine.
    struct GetMediaQueries
      include Protocol::Command
      include JSON::Serializable
      getter medias : Array(CSSMedia)
    end

    # Requests information about platform fonts which we used to render child TextNodes in the given
    # node.
    struct GetPlatformFontsForNode
      include Protocol::Command
      include JSON::Serializable
      # Usage statistics for every employed platform font.
      getter fonts : Array(PlatformFontUsage)
    end

    # Returns the current textual content for a stylesheet.
    struct GetStyleSheetText
      include Protocol::Command
      include JSON::Serializable
      # The stylesheet text.
      getter text : String
    end

    # Returns all layers parsed by the rendering engine for the tree scope of a node.
    # Given a DOM element identified by nodeId, getLayersForNode returns the root
    # layer for the nearest ancestor document or shadow root. The layer root contains
    # the full layer tree for the tree scope and their ordering.
    struct GetLayersForNode
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "rootLayer")]
      getter root_layer : CSSLayerData
    end

    # Starts tracking the given computed styles for updates. The specified array of properties
    # replaces the one previously specified. Pass empty array to disable tracking.
    # Use takeComputedStyleUpdates to retrieve the list of nodes that had properties modified.
    # The changes to computed style properties are only tracked for nodes pushed to the front-end
    # by the DOM agent. If no changes to the tracked properties occur after the node has been pushed
    # to the front-end, no updates will be issued for the node.
    struct TrackComputedStyleUpdates
      include Protocol::Command
      include JSON::Serializable
    end

    # Polls the next batch of computed style updates.
    struct TakeComputedStyleUpdates
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "nodeIds")]
      # The list of node Ids that have their tracked computed styles updated
      getter node_ids : Array(DOM::NodeId)
    end

    # Find a rule with the given active property for the given node and set the new value for this
    # property
    struct SetEffectivePropertyValueForNode
      include Protocol::Command
      include JSON::Serializable
    end

    # Modifies the keyframe rule key text.
    struct SetKeyframeKey
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "keyText")]
      # The resulting key text after modification.
      getter key_text : Value
    end

    # Modifies the rule selector.
    struct SetMediaText
      include Protocol::Command
      include JSON::Serializable
      # The resulting CSS media rule after modification.
      getter media : CSSMedia
    end

    # Modifies the expression of a container query.
    struct SetContainerQueryText
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "containerQuery")]
      # The resulting CSS container query rule after modification.
      getter container_query : CSSContainerQuery
    end

    # Modifies the expression of a supports at-rule.
    struct SetSupportsText
      include Protocol::Command
      include JSON::Serializable
      # The resulting CSS Supports rule after modification.
      getter supports : CSSSupports
    end

    # Modifies the expression of a scope at-rule.
    struct SetScopeText
      include Protocol::Command
      include JSON::Serializable
      # The resulting CSS Scope rule after modification.
      getter scope : CSSScope
    end

    # Modifies the rule selector.
    struct SetRuleSelector
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "selectorList")]
      # The resulting selector list after modification.
      getter selector_list : SelectorList
    end

    # Sets the new stylesheet text.
    struct SetStyleSheetText
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "sourceMapURL")]
      # URL of source map associated with script (if any).
      getter source_map_url : String?
    end

    # Applies specified style edits one after another in the given order.
    struct SetStyleTexts
      include Protocol::Command
      include JSON::Serializable
      # The resulting styles after modification.
      getter styles : Array(CSSStyle)
    end

    # Enables the selector recording.
    struct StartRuleUsageTracking
      include Protocol::Command
      include JSON::Serializable
    end

    # Stop tracking rule usage and return the list of rules that were used since last call to
    # `takeCoverageDelta` (or since start of coverage instrumentation)
    struct StopRuleUsageTracking
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "ruleUsage")]
      getter rule_usage : Array(RuleUsage)
    end

    # Obtain list of rules that became used since last call to this method (or since start of coverage
    # instrumentation)
    struct TakeCoverageDelta
      include Protocol::Command
      include JSON::Serializable
      getter coverage : Array(RuleUsage)
      # Monotonically increasing time, in seconds.
      getter timestamp : Number::Primitive
    end

    # Enables/disables rendering of local CSS fonts (enabled by default).
    struct SetLocalFontsEnabled
      include Protocol::Command
      include JSON::Serializable
    end

    # ----------------------------------------
    # CSS Section: events
    # ----------------------------------------

    # Fires whenever a web font is updated.  A non-empty font parameter indicates a successfully loaded
    # web font
    struct FontsUpdated
      include JSON::Serializable
      include Protocol::Event
      # The web font that has loaded.
      getter font : FontFace?
    end

    # Fires whenever a MediaQuery result changes (for example, after a browser window has been
    # resized.) The current implementation considers only viewport-dependent media features.
    struct MediaQueryResultChanged
      include JSON::Serializable
      include Protocol::Event
    end

    # Fired whenever an active document stylesheet is added.
    struct StyleSheetAdded
      include JSON::Serializable
      include Protocol::Event
      # Added stylesheet metainfo.
      getter header : CSSStyleSheetHeader
    end

    # Fired whenever a stylesheet is changed as a result of the client operation.
    struct StyleSheetChanged
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "styleSheetId")]
      getter style_sheet_id : StyleSheetId
    end

    # Fired whenever an active document stylesheet is removed.
    struct StyleSheetRemoved
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "styleSheetId")]
      # Identifier of the removed stylesheet.
      getter style_sheet_id : StyleSheetId
    end
  end
end
