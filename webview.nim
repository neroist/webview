## Wrapper for `Webview <https://github.com/webview/webview>`_.

import std/json
import std/os

const
  libs = currentSourcePath().parentDir() / "libs"
  # webview = libs / "webview"
  webview2Include {.used.} = libs / "webview2"/"build"/"native"/"include"
  isDebug = not (defined(release) or defined(danger))

when defined(useWebviewDll):
  const webviewDll* {.strdefine.} = 
    when defined(windows):
      "webview.dll"
    elif defined(macos):
      "libwebview.dynlib"
    else:
      "libwebview.so"

  {.pragma: webview, dynlib: webviewDll, discardable.}

elif defined(useWebviewStaticLib) or defined(useWebviewStaticLibrary):
  const webviewStaticLibrary* {.strdefine.} = 
    when defined(windows): #? vcc
      "webview.lib"
    else:
      "libwebview.a"

  {.passL: webviewStaticLibrary.}
  {.pragma: webview, discardable.}

else:
  {.passC: "-DWEBVIEW_STATIC".}

  when defined(windows) or defined(webviewEdge):
    {.passC: "-DWEBVIEW_EDGE".}

  when defined(vcc):
    {.passC: "/std:c++17".}
    {.passC: "/wd4005".} # disable warning C4005: 'WIN32_LEAN_AND_MEAN': macro redefinition
    {.passC: "/EHsc".}

    {.link: "advapi32.lib".}
    {.link: "ole32.lib".}
    {.link: "shell32.lib".}
    {.link: "shlwapi.lib".}
    {.link: "user32.lib".}
    {.link: "version.lib".}

    {.passC: "/I " & webview2Include.}

  elif defined(windows):
    {.passC: "-I" & webview2Include.}
    {.passL: "-mwindows".}

    when defined(gcc):
      {.passC: "-std=c++17".}

    when not defined(clang): # gives warning on clang
      {.passL: "-lstdc++".}

    {.passL: "-ladvapi32".}
    {.passL: "-lole32".}
    {.passL: "-lshell32".}
    {.passL: "-lshlwapi".}
    {.passL: "-luser32".}
    {.passL: "-lversion".}
    {.passL: "-static".}
  else:
    when defined(cpp):
      {.passC: "-std=c++11".}

    when defined(macosx) or defined(macos) or defined(webviewCocoa):
      {.passC: "-DWEBVIEW_COCOA".}

      {.passL: "-framework WebKit".}

    when defined(linux) or defined(bsd) or defined(webviewGtk):
      {.passC: "-DWEBVIEW_GTK".}

      {.passL: staticExec"pkg-config --libs gtk+-3.0 webkit2gtk-4.0".}
      {.passC: staticExec"pkg-config --cflags gtk+-3.0 webkit2gtk-4.0".}

  {.compile: libs / "webview" / "webview.cc".}
  {.pragma: webview, discardable.}

const
  WEBVIEW_VERSION_MAJOR*          = 0  ## The current library major version.
  WEBVIEW_VERSION_MINOR*          = 11 ## The current library minor version.
  WEBVIEW_VERSION_PATCH*          = 0  ## The current library patch version.
  WEBVIEW_VERSION_PRE_RELEASE*    = "" ## SemVer 2.0.0 pre-release labels prefixed with "-".
  WEBVIEW_VERSION_BUILD_METADATA* = "" ## SemVer 2.0.0 build metadata prefixed with "+".
  WEBVIEW_VERSION_NUMBER*         = $WEBVIEW_VERSION_MAJOR &
                              '.' & $WEBVIEW_VERSION_MINOR &
                              '.' & $WEBVIEW_VERSION_PATCH ## \
    ## SemVer 2.0.0 version number in MAJOR.MINOR.PATCH format.

type
  WebviewVersion* {.bycopy.} = object
    ## Holds the elements of a MAJOR.MINOR.PATCH version number.

    major*, minor*, patch*: cuint

  WebviewVersionInfo* {.bycopy.} = object
    ## Holds the library's version information.

    version*: WebviewVersion
      ## The elements of the version number.

    versionNumber*: array[32, char]
      ## SemVer 2.0.0 version number in `MAJOR.MINOR.PATCH` format.

    preRelease*: array[48, char]
      ## SemVer 2.0.0 pre-release labels prefixed with "-" if specified, otherwise
      ## an empty string.

    buildMetadata*: array[48, char]
      ## SemVer 2.0.0 build metadata prefixed with "+", otherwise an empty string.

  Webview* = pointer
    ## Pointer to a webview instance.

  WebviewNativeHandleKind* = enum
    ## Native handle kind. The actual type depends on the backend.

    WebviewNativeHandleKindUiWindow
      ## Top-level window. `GtkWindow` pointer (GTK), `NSWindow` pointer (Cocoa)
      ## or `HWND` (Win32).

    WebviewNativeHandleKindUiWidget
      ## Browser widget. `GtkWidget` pointer (GTK), `NSView` pointer (Cocoa) or
      ## `HWND` (Win32).

    WebviewNativeHandleKindBrowserController
      ## Browser controller. `WebKitWebView` pointer (WebKitGTK), `WKWebView`
      ## pointer (Cocoa/WebKit) or `ICoreWebView2Controller` pointer
      ## (Win32/WebView2).

  WebviewHint* = enum
    ## Window size hints

    WebviewHintNone
      ## Width and height are default size.

    WebviewHintMin
      ## Width and height are minimum bounds.

    WebviewHintMax
      ## Width and height are maximum bounds.

    WebviewHintFixed
      ## Window size can not be changed by a user.
  
  WebviewError* = enum
    ## Error codes returned to callers of the API.
    ## 
    ## The following codes are commonly used in the library:
    ## - `WebviewErrorOk`
    ## - `WebviewErrorUnspecified`
    ## - `WebviewErrorInvalidArgument`
    ## - `WebviewErrorInvalidState`
    ## 
    ## With the exception of `WebviewErrorOk` which is normally expected,
    ## the other common codes do not normally need to be handled specifically.
    ## Refer to specific functions regarding handling of other codes.

    WebviewErrorMissingDependency = -5
      ## Missing dependency.

    WebviewErrorCanceled = -4
      ## Operation canceled.

    WebviewErrorInvalidState = -3
      ## Invalid state detected.

    WebviewErrorInvalidArgument = -2
      ## One or more invalid arguments have been specified e.g. in a function call.

    WebviewErrorUnspecified = -1
      ## An unspecified error occurred. A more specific error code may be needed.

    WebviewErrorOk = 0
      ## OK/Success. Functions that return error codes will typically return this
      ## to signify successful operations.

    WebviewErrorDuplicate = 1
      ## Signifies that something already exists.

    WebviewErrorNotFound = 2
      ## Signifies that something does not exist.

const
  wnhkUiWindow* = WebviewNativeHandleKindUiWindow
  wnhkUiWidget* = WebviewNativeHandleKindUiWidget
  wnhkController* = WebviewNativeHandleKindBrowserController
  
  whNone* = WebviewHintNone
  whMin* = WebviewHintMin
  whMax* = WebviewHintMax
  whFixed* = WebviewHintFixed
  
  weMissingDependency* = WebviewErrorMissingDependency
  weCanceled* = WebviewErrorCanceled
  weInvalidState* = WebviewErrorInvalidState
  weInvalidArgument* = WebviewErrorInvalidArgument
  weUnspecified* = WebviewErrorUnspecified
  weOk* = WebviewErrorOk
  weDuplicate* = WebviewErrorDuplicate
  weNotFound* = WebviewErrorNotFound

proc create*(debug: cint = cint isDebug;
    window: pointer = nil): Webview {.cdecl, importc: "webview_create", webview.}
  ## Creates a new webview instance.
  ## 
  ## :debug: Enable developer tools if supported by the backend.
  ## :window: Optional native window handle, i.e. `GtkWindow` pointer
  ##          `NSWindow` pointer (Cocoa) or `HWND` (Win32). If non-nil,
  ##          the webview widget is embedded into the given window, and the
  ##          caller is expected to assume responsibility for the window as
  ##          well as application lifecycle. If the window handle is nil,
  ##          a new window is created and both the window and application
  ##          lifecycle are managed by the webview instance.
  ##
  ## .. note:: Win32: The function also accepts a pointer to `HWND` (Win32) in the
  ##          window parameter for backward compatibility.
  ##
  ## .. note:: Win32/WebView2: `CoInitializeEx` should be called with
  ##           `COINIT_APARTMENTTHREADED` before attempting to call this function
  ##           with an existing window. Omitting this step may cause WebView2
  ##           initialization to fail.
  ##
  ## :return: `nil` on failure. Creation can fail for various reasons such
  ##          as when required runtime dependencies are missing or when window
  ##          creation fails.
  ## :retval: `WEBVIEW_ERROR_MISSING_DEPENDENCY`
  ##          May be returned if WebView2 is unavailable on Windows.

proc destroy*(w: Webview): WebviewError {.cdecl, importc: "webview_destroy", webview.}
  ## Destroys a webview and closes the native window.
  ##
  ## :w: The webview instance.

proc run*(w: Webview): WebviewError {.cdecl, importc: "webview_run", webview.}
  ## Runs the main loop until it's terminated.
  ##
  ## :w: The webview instance.

proc terminate*(w: Webview): WebviewError {.cdecl, importc: "webview_terminate", webview.}
  ## Stops the main loop. It is safe to call this function from another other
  ## background thread.
  ##
  ## :w: The webview instance.

proc dispatch*(w: Webview; fn: proc (w: Webview; arg: pointer) {.cdecl.};
                     arg: pointer = nil): WebviewError {.cdecl, importc: "webview_dispatch",
                     webview.}
  ## Schedules a function to be invoked on the thread with the run/event loop.
  ## Use this function e.g. to interact with the library or native handles.
  ## 
  ## :w: The webview instance.
  ## :fn: The function to be invoked.
  ## :arg: An optional argument passed along to the callback function.

proc getWindow*(w: Webview): pointer {.cdecl, importc: "webview_get_window",
                                      webview.}
  ## Returns the native handle of the window associated with the webview instance.
  ## The handle can be a `GtkWindow` pointer (GTK), `NSWindow` pointer (Cocoa)
  ## or `HWND` (Win32).
  ## 
  ## :w: The webview instance.
  ## :return: The handle of the native window.

proc getNativeHandle*(w: Webview, kind: WebviewNativeHandleKind): pointer {.cdecl, importc: "webview_get_native_handle",
                                      webview.}
  ## Get a native handle of choice.
  ## 
  ## :w: The webview instance.
  ## :kind: The kind of handle to retrieve.
  ## :return: The native handle or `nil`.

proc setTitle*(w: Webview; title: cstring): WebviewError {.cdecl,
    importc: "webview_set_title", webview.}
  ## Updates the title of the native window.
  ## 
  ## :w: The webview instance.
  ## :title: The new title.

proc setSize*(w: Webview; width: cint; height: cint;
    hints: WebviewHint = WEBVIEW_HINT_NONE): WebviewError {.cdecl,
    importc: "webview_set_size", webview.}
  ## Updates the size of the native window.
  ## 
  ## :w: The webview instance.
  ## :width: New width.
  ## :height: New height.
  ## :hints: Size hints.

proc navigate*(w: Webview; url: cstring): WebviewError {.cdecl,
    importc: "webview_navigate", webview.} =
  ## Navigates webview to the given URL. URL may be a properly encoded data URI.
  ##
  ## :w: The webview instance.
  ## :url: URL.

  runnableExamples:
    let w = newWebview()

    w.navigate("https://github.com/webview/webview")
    w.navigate("data:text/html,%3Ch1%3EHello%3C%2Fh1%3E")
    w.navigate("data:text/html;base64,PGgxPkhlbGxvPC9oMT4=")

proc setHtml*(w: Webview; html: cstring): WebviewError {.cdecl,
    importc: "webview_set_html", webview.} =
  ## Load HTML content into the webview.
  ##
  ## :w: The webview instance.
  ## :html: HTML content.

  runnableExamples:
    let w = newWebview()

    w.setHtml("<h1>Hello</h1>")

proc init*(w: Webview; js: cstring): WebviewError {.cdecl, importc: "webview_init", webview.}
  ## Injects JavaScript code to be executed immediately upon loading a page.
  ## The code will be executed before `window.onload`.
  ## 
  ## :w: The webview instance.
  ## :js: JS content.

proc eval*(w: Webview; js: cstring): WebviewError {.cdecl, importc: "webview_eval", webview.}
  ## Evaluates arbitrary JavaScript code.
  ##
  ## Use bindings if you need to communicate the result of the evaluation.
  ##
  ## :w: The webview instance.
  ## :js: JS content.

proc webviewBind*(w: Webview; name: cstring;
                 fn: proc (id: cstring; req: cstring; arg: pointer) {.cdecl.};
                 arg: pointer = nil): WebviewError {.cdecl, importc: "webview_bind", webview.}
  ## Binds a function pointer to a new global JavaScript function.
  ## 
  ## Internally, JS glue code is injected to create the JS function by the
  ## given name. The callback function is passed a request identifier,
  ## a request string and a user-provided argument. The request string is
  ## a JSON array of the arguments passed to the JS function.
  ## 
  ## :w: The webview instance.
  ## :name: Name of the JS function.
  ## :fn: Callback function.
  ## :arg: User argument.
  ## :retval: `WEBVIEW_ERROR_DUPLICATE`
  ##          A binding already exists with the specified name.

proc unbind*(w: Webview; name: cstring): WebviewError {.cdecl,
                                importc: "webview_unbind", webview.}
  ## Removes a binding created with webview_bind().
  ## 
  ## :w: The webview instance.
  ## :name: Name of the binding.
  ## :retval: `WEBVIEW_ERROR_NOT_FOUND` 
  ##          No binding exists with the specified name.

proc webviewReturn*(w: Webview; seq: cstring; status: cint;
    result: cstring): WebviewError {.cdecl, importc: "webview_return", webview.}
  ## Responds to a binding call from the JS side.
  ## 
  ## :w: The webview instance.
  ## :id: The identifier of the binding call. Pass along the value received
  ##       in the binding handler (see `webviewBind()`_).
  ## :status: A status of zero tells the JS side that the binding call was
  ##          succesful; any other value indicates an error.
  ## :result: The result of the binding call to be returned to the JS side.
  ##          This must either be a valid JSON value or an empty string for
  ##          the primitive JS value `undefined`.

proc webviewVersion*(): ptr WebviewVersionInfo {.cdecl,
    importc: "webview_version", webview.}
  ## Get the library's version information.

# -------------------

type
  CallBackContext = ref object
    w: Webview
    fn: proc (id: string; req: JsonNode): string

proc version*(): WebviewVersionInfo {.inline, deprecated: "Useless. use `webviewVersion()`_ instead".} = webviewVersion()[]
  ## Dereferenced version of `webviewVersion() <#webviewVersion>`_.
  ##
  ## Same as `webviewVersion()[]`.

proc closure(id: cstring; req: cstring; arg: pointer) {.cdecl.} =
  var err: cint
  let ctx = cast[CallBackContext](arg)

  let res = 
    try:
      ctx.fn($id, parseJson($req))
    except CatchableError:
      err = -1
      $ %* getCurrentExceptionMsg()

  webviewReturn(ctx.w, id, err, cstring res)

proc bindCallback*(w: Webview; name: string;
                 fn: proc (id: string; req: JsonNode): string): WebviewError {.discardable.} =
  ## Essentially a high-level version of
  ## `webviewBind <#webviewBind,Webview,cstring,proc(cstring,cstring,pointer),pointer>`_
  
  #      using global seems to work...
  # TODO is there a better solution?
  let arg {.global.} = CallBackContext(w: w, fn: fn)

  result = w.webviewBind(name, closure, cast[pointer](arg))

proc `bind`*(w: Webview; name: string;
                 fn: proc (id: string; req: JsonNode): string): WebviewError {.inline, discardable.} =
  ## Alias of 
  ## `bindCallback() <#bindCallback,Webview,string,proc(string,JsonNode)>`_
  
  w.bindCallback(name, fn)

proc setSize*(w: Webview; width: int; height: int;
    hints: WebviewHint = WebviewHintNone): WebviewError {.inline, discardable.} =
  ## Alias of `setSize()`_ with `int` instead of `cint`

  w.setSize(cint width, cint height, hints)

proc `html=`*(w: Webview; html: string): WebviewError {.inline, discardable.} =
  ## Setter alias for `setHtml()`_.

  runnableExamples:
    let w = newWebview()

    w.html = "<h1>Hello</h1>"

  w.setHtml(cstring html)

proc `size=`*(w: Webview; size: tuple[width: int; height: int]): WebviewError {.inline, discardable.} =
  ## Setter alias for `setSize()`. `hints` default to `WEBVIEW_HINT_NONE`.

  w.setSize(cint size.width, cint size.height, WEBVIEW_HINT_NONE)

proc `title=`*(w: Webview; title: string): WebviewError {.inline, discardable.} =
  ## Setter alias for `setTitle()`.

  w.setTitle(title)

proc newWebview*(debug: bool = isDebug; window: pointer = nil): Webview {.inline.} =
  ## Alias of `create()`

  create(cint debug, window)

export JsonNode
