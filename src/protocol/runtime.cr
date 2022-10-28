# ================================================================================
# Runtime domain exposes JavaScript runtime by means of remote evaluation and mirror objects.
# Evaluation results are returned as mirror object that expose object type, string representation
# and unique identifier that can be used for further object reference. Original objects are
# maintained in memory unless they are either explicitly released or are released along with the
# other objects in their object group.
# ================================================================================

# common Command module
require "./command"
# common Event module
require "./event"

module Protocol
  module Runtime
    # ----------------------------------------
    # Runtime Section: types
    # ----------------------------------------

    # Unique script identifier.
    alias ScriptId = String

    # Represents the value serialiazed by the WebDriver BiDi specification
    # https://w3c.github.io/webdriver-bidi.
    struct WebDriverValue
      include JSON::Serializable
      getter type : String
      getter value : JSON::Any?
      @[JSON::Field(key: "objectId")]
      getter object_id : String?
    end

    # Unique object identifier.
    alias RemoteObjectId = String

    # Primitive value which cannot be JSON-stringified. Includes values `-0`, `NaN`, `Infinity`,
    # `-Infinity`, and bigint literals.
    alias UnserializableValue = String

    # Mirror object referencing original JavaScript object.
    struct RemoteObject
      include JSON::Serializable
      # Object type.
      getter type : String
      # Object subtype hint. Specified for `object` type values only.
      # NOTE: If you change anything here, make sure to also update
      # `subtype` in `ObjectPreview` and `PropertyPreview` below.
      getter subtype : String?
      @[JSON::Field(key: "className")]
      # Object class (constructor) name. Specified for `object` type values only.
      getter class_name : String?
      # Remote object value in case of primitive values or JSON values (if it was requested).
      getter value : JSON::Any?
      @[JSON::Field(key: "unserializableValue")]
      # Primitive value which can not be JSON-stringified does not have `value`, but gets this
      # property.
      getter unserializable_value : UnserializableValue?
      # String representation of the object.
      getter description : String?
      @[JSON::Field(key: "webDriverValue")]
      # WebDriver BiDi representation of the value.
      getter web_driver_value : WebDriverValue?
      @[JSON::Field(key: "objectId")]
      # Unique object identifier (for non-primitive values).
      getter object_id : RemoteObjectId?
      # Preview containing abbreviated property values. Specified for `object` type values only.
      getter preview : ObjectPreview?
      @[JSON::Field(key: "customPreview")]
      getter custom_preview : CustomPreview?
    end

    struct CustomPreview
      include JSON::Serializable
      # The JSON-stringified result of formatter.header(object, config) call.
      # It contains json ML array that represents RemoteObject.
      getter header : String
      @[JSON::Field(key: "bodyGetterId")]
      # If formatter returns true as a result of formatter.hasBody call then bodyGetterId will
      # contain RemoteObjectId for the function that returns result of formatter.body(object, config) call.
      # The result value is json ML array.
      getter body_getter_id : RemoteObjectId?
    end

    # Object containing abbreviated remote object value.
    struct ObjectPreview
      include JSON::Serializable
      # Object type.
      getter type : String
      # Object subtype hint. Specified for `object` type values only.
      getter subtype : String?
      # String representation of the object.
      getter description : String?
      # True iff some of the properties or entries of the original object did not fit.
      getter overflow : Bool
      # List of the properties.
      getter properties : Array(PropertyPreview)
      # List of the entries. Specified for `map` and `set` subtype values only.
      getter entries : Array(EntryPreview)?
    end

    struct PropertyPreview
      include JSON::Serializable
      # Property name.
      getter name : String
      # Object type. Accessor means that the property itself is an accessor property.
      getter type : String
      # User-friendly property value string.
      getter value : String?
      @[JSON::Field(key: "valuePreview")]
      # Nested value preview.
      getter value_preview : ObjectPreview?
      # Object subtype hint. Specified for `object` type values only.
      getter subtype : String?
    end

    struct EntryPreview
      include JSON::Serializable
      # Preview of the key. Specified for map-like collection entries.
      getter key : ObjectPreview?
      # Preview of the value.
      getter value : ObjectPreview
    end

    # Object property descriptor.
    struct PropertyDescriptor
      include JSON::Serializable
      # Property name or symbol description.
      getter name : String
      # The value associated with the property.
      getter value : RemoteObject?
      # True if the value associated with the property may be changed (data descriptors only).
      getter writable : Bool?
      # A function which serves as a getter for the property, or `undefined` if there is no getter
      # (accessor descriptors only).
      getter get : RemoteObject?
      # A function which serves as a setter for the property, or `undefined` if there is no setter
      # (accessor descriptors only).
      getter set : RemoteObject?
      # True if the type of this property descriptor may be changed and if the property may be
      # deleted from the corresponding object.
      getter configurable : Bool
      # True if this property shows up during enumeration of the properties on the corresponding
      # object.
      getter enumerable : Bool
      @[JSON::Field(key: "wasThrown")]
      # True if the result was thrown during the evaluation.
      getter was_thrown : Bool?
      @[JSON::Field(key: "isOwn")]
      # True if the property is owned for the object.
      getter is_own : Bool?
      # Property symbol object, if the property is of the `symbol` type.
      getter symbol : RemoteObject?
    end

    # Object internal property descriptor. This property isn't normally visible in JavaScript code.
    struct InternalPropertyDescriptor
      include JSON::Serializable
      # Conventional property name.
      getter name : String
      # The value associated with the property.
      getter value : RemoteObject?
    end

    # Object private field descriptor.
    struct PrivatePropertyDescriptor
      include JSON::Serializable
      # Private property name.
      getter name : String
      # The value associated with the private property.
      getter value : RemoteObject?
      # A function which serves as a getter for the private property,
      # or `undefined` if there is no getter (accessor descriptors only).
      getter get : RemoteObject?
      # A function which serves as a setter for the private property,
      # or `undefined` if there is no setter (accessor descriptors only).
      getter set : RemoteObject?
    end

    # Represents function call argument. Either remote object id `objectId`, primitive `value`,
    # unserializable primitive value or neither of (for undefined) them should be specified.
    struct CallArgument
      include JSON::Serializable
      # Primitive value or serializable javascript object.
      getter value : JSON::Any?
      @[JSON::Field(key: "unserializableValue")]
      # Primitive value which can not be JSON-stringified.
      getter unserializable_value : UnserializableValue?
      @[JSON::Field(key: "objectId")]
      # Remote object handle.
      getter object_id : RemoteObjectId?
    end

    # Id of an execution context.
    alias ExecutionContextId = Int::Primitive

    # Description of an isolated world.
    struct ExecutionContextDescription
      include JSON::Serializable
      # Unique id of the execution context. It can be used to specify in which execution context
      # script evaluation should be performed.
      getter id : ExecutionContextId
      # Execution context origin.
      getter origin : String
      # Human readable name describing given context.
      getter name : String
      @[JSON::Field(key: "uniqueId")]
      # A system-unique execution context identifier. Unlike the id, this is unique across
      # multiple processes, so can be reliably used to identify specific context while backend
      # performs a cross-process navigation.
      getter unique_id : String
      @[JSON::Field(key: "auxData")]
      # Embedder-specific auxiliary data.
      getter aux_data : JSON::Any?
    end

    # Detailed information about exception (or error) that was thrown during script compilation or
    # execution.
    struct ExceptionDetails
      include JSON::Serializable
      @[JSON::Field(key: "exceptionId")]
      # Exception id.
      getter exception_id : Int::Primitive
      # Exception text, which should be used together with exception object when available.
      getter text : String
      @[JSON::Field(key: "lineNumber")]
      # Line number of the exception location (0-based).
      getter line_number : Int::Primitive
      @[JSON::Field(key: "columnNumber")]
      # Column number of the exception location (0-based).
      getter column_number : Int::Primitive
      @[JSON::Field(key: "scriptId")]
      # Script ID of the exception location.
      getter script_id : ScriptId?
      # URL of the exception location, to be used when the script was not reported.
      getter url : String?
      @[JSON::Field(key: "stackTrace")]
      # JavaScript stack trace if available.
      getter stack_trace : StackTrace?
      # Exception object if available.
      getter exception : RemoteObject?
      @[JSON::Field(key: "executionContextId")]
      # Identifier of the context where exception happened.
      getter execution_context_id : ExecutionContextId?
      @[JSON::Field(key: "exceptionMetaData")]
      # Dictionary with entries of meta data that the client associated
      # with this exception, such as information about associated network
      # requests, etc.
      getter exception_meta_data : JSON::Any?
    end

    # Number of milliseconds since epoch.
    alias Timestamp = Number::Primitive

    # Number of milliseconds.
    alias TimeDelta = Number::Primitive

    # Stack entry for runtime errors and assertions.
    struct CallFrame
      include JSON::Serializable
      @[JSON::Field(key: "functionName")]
      # JavaScript function name.
      getter function_name : String
      @[JSON::Field(key: "scriptId")]
      # JavaScript script id.
      getter script_id : ScriptId
      # JavaScript script name or url.
      getter url : String
      @[JSON::Field(key: "lineNumber")]
      # JavaScript script line number (0-based).
      getter line_number : Int::Primitive
      @[JSON::Field(key: "columnNumber")]
      # JavaScript script column number (0-based).
      getter column_number : Int::Primitive
    end

    # Call frames for assertions or error messages.
    class StackTrace
      include JSON::Serializable
      # String label of this stack trace. For async traces this may be a name of the function that
      # initiated the async call.
      getter description : String?
      @[JSON::Field(key: "callFrames")]
      # JavaScript function name.
      getter call_frames : Array(CallFrame)
      # Asynchronous JavaScript stack trace that preceded this stack, if available.
      getter parent : StackTrace?
      @[JSON::Field(key: "parentId")]
      # Asynchronous JavaScript stack trace that preceded this stack, if available.
      getter parent_id : StackTraceId?
    end

    # Unique identifier of current debugger.
    alias UniqueDebuggerId = String

    # If `debuggerId` is set stack trace comes from another debugger and can be resolved there. This
    # allows to track cross-debugger calls. See `Runtime.StackTrace` and `Debugger.paused` for usages.
    struct StackTraceId
      include JSON::Serializable
      getter id : String
      @[JSON::Field(key: "debuggerId")]
      getter debugger_id : UniqueDebuggerId?
    end

    # ----------------------------------------
    # Runtime Section: commands
    # ----------------------------------------

    # Add handler to promise with given promise object id.
    struct AwaitPromise
      include Protocol::Command
      include JSON::Serializable
      # Promise result. Will contain rejected value if promise was rejected.
      getter result : RemoteObject
      @[JSON::Field(key: "exceptionDetails")]
      # Exception details if stack strace is available.
      getter exception_details : ExceptionDetails?
    end

    # Calls function with given declaration on the given object. Object group of the result is
    # inherited from the target object.
    struct CallFunctionOn
      include Protocol::Command
      include JSON::Serializable
      # Call result.
      getter result : RemoteObject
      @[JSON::Field(key: "exceptionDetails")]
      # Exception details.
      getter exception_details : ExceptionDetails?
    end

    # Compiles expression.
    struct CompileScript
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "scriptId")]
      # Id of the script.
      getter script_id : ScriptId?
      @[JSON::Field(key: "exceptionDetails")]
      # Exception details.
      getter exception_details : ExceptionDetails?
    end

    # Disables reporting of execution contexts creation.
    struct Disable
      include Protocol::Command
      include JSON::Serializable
    end

    # Discards collected exceptions and console API calls.
    struct DiscardConsoleEntries
      include Protocol::Command
      include JSON::Serializable
    end

    # Enables reporting of execution contexts creation by means of `executionContextCreated` event.
    # When the reporting gets enabled the event will be sent immediately for each existing execution
    # context.
    struct Enable
      include Protocol::Command
      include JSON::Serializable
    end

    # Evaluates expression on global object.
    struct Evaluate
      include Protocol::Command
      include JSON::Serializable
      # Evaluation result.
      getter result : RemoteObject
      @[JSON::Field(key: "exceptionDetails")]
      # Exception details.
      getter exception_details : ExceptionDetails?
    end

    # Returns the isolate id.
    struct GetIsolateId
      include Protocol::Command
      include JSON::Serializable
      # The isolate id.
      getter id : String
    end

    # Returns the JavaScript heap usage.
    # It is the total usage of the corresponding isolate not scoped to a particular Runtime.
    struct GetHeapUsage
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "usedSize")]
      # Used heap size in bytes.
      getter used_size : Number::Primitive
      @[JSON::Field(key: "totalSize")]
      # Allocated heap size in bytes.
      getter total_size : Number::Primitive
    end

    # Returns properties of a given object. Object group of the result is inherited from the target
    # object.
    struct GetProperties
      include Protocol::Command
      include JSON::Serializable
      # Object properties.
      getter result : Array(PropertyDescriptor)
      @[JSON::Field(key: "internalProperties")]
      # Internal object properties (only of the element itself).
      getter internal_properties : Array(InternalPropertyDescriptor)?
      @[JSON::Field(key: "privateProperties")]
      # Object private properties.
      getter private_properties : Array(PrivatePropertyDescriptor)?
      @[JSON::Field(key: "exceptionDetails")]
      # Exception details.
      getter exception_details : ExceptionDetails?
    end

    # Returns all let, const and class variables from global scope.
    struct GlobalLexicalScopeNames
      include Protocol::Command
      include JSON::Serializable
      getter names : Array(String)
    end

    struct QueryObjects
      include Protocol::Command
      include JSON::Serializable
      # Array with objects.
      getter objects : RemoteObject
    end

    # Releases remote object with given id.
    struct ReleaseObject
      include Protocol::Command
      include JSON::Serializable
    end

    # Releases all remote objects that belong to a given group.
    struct ReleaseObjectGroup
      include Protocol::Command
      include JSON::Serializable
    end

    # Tells inspected instance to run if it was waiting for debugger to attach.
    struct RunIfWaitingForDebugger
      include Protocol::Command
      include JSON::Serializable
    end

    # Runs script with given id in a given context.
    struct RunScript
      include Protocol::Command
      include JSON::Serializable
      # Run result.
      getter result : RemoteObject
      @[JSON::Field(key: "exceptionDetails")]
      # Exception details.
      getter exception_details : ExceptionDetails?
    end

    # Enables or disables async call stacks tracking.
    struct SetAsyncCallStackDepth
      include Protocol::Command
      include JSON::Serializable
    end

    struct SetCustomObjectFormatterEnabled
      include Protocol::Command
      include JSON::Serializable
    end

    struct SetMaxCallStackSizeToCapture
      include Protocol::Command
      include JSON::Serializable
    end

    # Terminate current or next JavaScript execution.
    # Will cancel the termination when the outer-most script execution ends.
    struct TerminateExecution
      include Protocol::Command
      include JSON::Serializable
    end

    # If executionContextId is empty, adds binding with the given name on the
    # global objects of all inspected contexts, including those created later,
    # bindings survive reloads.
    # Binding function takes exactly one argument, this argument should be string,
    # in case of any other input, function throws an exception.
    # Each binding function call produces Runtime.bindingCalled notification.
    struct AddBinding
      include Protocol::Command
      include JSON::Serializable
    end

    # This method does not remove binding function from global object but
    # unsubscribes current runtime agent from Runtime.bindingCalled notifications.
    struct RemoveBinding
      include Protocol::Command
      include JSON::Serializable
    end

    # This method tries to lookup and populate exception details for a
    # JavaScript Error object.
    # Note that the stackTrace portion of the resulting exceptionDetails will
    # only be populated if the Runtime domain was enabled at the time when the
    # Error was thrown.
    struct GetExceptionDetails
      include Protocol::Command
      include JSON::Serializable
      @[JSON::Field(key: "exceptionDetails")]
      getter exception_details : ExceptionDetails?
    end

    # ----------------------------------------
    # Runtime Section: events
    # ----------------------------------------

    # Notification is issued every time when binding is called.
    struct BindingCalled
      include JSON::Serializable
      include Protocol::Event
      getter name : String
      getter payload : String
      @[JSON::Field(key: "executionContextId")]
      # Identifier of the context where the call was made.
      getter execution_context_id : ExecutionContextId
    end

    # Issued when console API was called.
    struct ConsoleAPICalled
      include JSON::Serializable
      include Protocol::Event
      # Type of the call.
      getter type : String
      # Call arguments.
      getter args : Array(RemoteObject)
      @[JSON::Field(key: "executionContextId")]
      # Identifier of the context where the call was made.
      getter execution_context_id : ExecutionContextId
      # Call timestamp.
      getter timestamp : Timestamp
      @[JSON::Field(key: "stackTrace")]
      # Stack trace captured when the call was made. The async stack chain is automatically reported for
      # the following call types: `assert`, `error`, `trace`, `warning`. For other types the async call
      # chain can be retrieved using `Debugger.getStackTrace` and `stackTrace.parentId` field.
      getter stack_trace : StackTrace?
      # Console context descriptor for calls on non-default console context (not console.*):
      # 'anonymous#unique-logger-id' for call on unnamed context, 'name#unique-logger-id' for call
      # on named context.
      getter context : String?
    end

    # Issued when unhandled exception was revoked.
    struct ExceptionRevoked
      include JSON::Serializable
      include Protocol::Event
      # Reason describing why exception was revoked.
      getter reason : String
      @[JSON::Field(key: "exceptionId")]
      # The id of revoked exception, as reported in `exceptionThrown`.
      getter exception_id : Int::Primitive
    end

    # Issued when exception was thrown and unhandled.
    struct ExceptionThrown
      include JSON::Serializable
      include Protocol::Event
      # Timestamp of the exception.
      getter timestamp : Timestamp
      @[JSON::Field(key: "exceptionDetails")]
      getter exception_details : ExceptionDetails
    end

    # Issued when new execution context is created.
    struct ExecutionContextCreated
      include JSON::Serializable
      include Protocol::Event
      # A newly created execution context.
      getter context : ExecutionContextDescription
    end

    # Issued when execution context is destroyed.
    struct ExecutionContextDestroyed
      include JSON::Serializable
      include Protocol::Event
      @[JSON::Field(key: "executionContextId")]
      # Id of the destroyed context
      getter execution_context_id : ExecutionContextId
    end

    # Issued when all executionContexts were cleared in browser
    struct ExecutionContextsCleared
      include JSON::Serializable
      include Protocol::Event
    end

    # Issued when object should be inspected (for example, as a result of inspect() command line API
    # call).
    struct InspectRequested
      include JSON::Serializable
      include Protocol::Event
      getter object : RemoteObject
      getter hints : JSON::Any
      @[JSON::Field(key: "executionContextId")]
      # Identifier of the context where the call was made.
      getter execution_context_id : ExecutionContextId?
    end
  end
end
