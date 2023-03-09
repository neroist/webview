## Wrapper for `Webview <https://github.com/webview/webview>`_.

import std/json
import std/os

const
  libs = currentSourcePath().parentDir() / "libs"

  webview2Include = libs / "webview2"/"build"/"native"/"include"
  webview = libs / "webview"

when defined(useWebviewDll):
  const webviewDll {.strdefine.} = when defined(windows):
      "webview.dll"
    elif defined(macos):
      "webview.dynlib"
    else:
      "webview.so"

  {.pragma: webview, dynlib: webviewDll.}

elif defined(useWebviewStaticLib) or defined(useWebviewStaticLibrary):
  const webviewStaticLibrary {.strdefine.} = when defined(windows):
      "webview.lib"
    else:
      "webview.a"

  {.passL: webviewStaticLibrary.}
  {.pragma: webview.}

else:
  when defined(forceWebviewGtk):
    {.passC: "-DWEBVIEW_GTK".}

  when defined(vcc):
    {.passC: "/std:c++17".}
    {.passC: "/EHsc".}

    {.link: "advapi32.lib".}
    {.link: "ole32.lib".}
    {.link: "shell32.lib".}
    {.link: "shlwapi.lib".}
    {.link: "user32.lib".}
    {.link: "version.lib".}

    {.passC: "/I " & webview2Include.}
    {.passC: "/I " & webview.}

  elif defined(windows) or defined(gcc):
    when defined(cpp):
      {.passC: "-std=c++17".}
    else:
      when not defined(clang):
        {.passC: "-std=c99".}

    {.passC: "-I" & webview2Include.}
    {.passC: "-I" & webview.}

    when defined(clang) and defined(cpp):
      {.passL: "-mwindows".}
    else:
      {.passC: "-mwindows".}

    {.passL: "-ladvapi32".}
    {.passL: "-lole32".}
    {.passL: "-lshell32".}
    {.passL: "-lshlwapi".}
    {.passL: "-luser32".}
    {.passL: "-lversion".}
    {.passL: "-static".}
  else:
    {.passC: "-I" & webview.}

    when defined(cpp):
      {.passC: "-std=c++11".}
    else:
      when not defined(clang):
        {.passC: "-std=c99".}

    when defined(macos):
      {.passL: "-framework Cocoa".}
      {.passL: "-framework WebKit".}

    when defined(linux) or defined(openbsd) or defined(freebsd) or defined(netbsd):
      when defined(cpp):
        {.passC: staticExec"pkg-config --cflags --libs gtk+-3.0 webkit2gtk-4.0".}
      else:
        {.passC: staticExec"pkg-config --cflags gtk+-3.0 webkit2gtk-4.0".}
        {.passL: staticExec"pkg-config --libs gtk+-3.0 webkit2gtk-4.0".}

  {.compile: libs / "webview" / "webview.cc".}
  {.pragma: webview.}

const
  WEBVIEW_VERSION_MAJOR*          = 0  ## The current library major version.
  WEBVIEW_VERSION_MINOR*          = 10 ## The current library minor version.
  WEBVIEW_VERSION_PATCH*          = 0  ## The current library patch version.
  WEBVIEW_VERSION_PRE_RELEASE*    = "" ## SemVer 2.0.0 pre-release labels prefixed with "-".
  WEBVIEW_VERSION_BUILD_METADATA* = "" ## SemVer 2.0.0 build metadata prefixed with "+".
  WEBVIEW_VERSION_NUMBER* = $WEBVIEW_VERSION_MAJOR &
                              '.' & $WEBVIEW_VERSION_MINOR &
                              '.' & $WEBVIEW_VERSION_PATCH ## \
    ## SemVer 2.0.0 version number in MAJOR.MINOR.PATCH format.

type
  WebviewVersion* {.bycopy.} = object
    major*, minor*, patch*: cuint

  WebviewVersionInfo* {.bycopy.} = object
    version*: WebviewVersion
    versionNumber*: array[32, char]
    preRelease*: array[48, char]
    buildMetadata*: array[48, char]

  Webview* = pointer

proc create*(debug: cint | bool = not defined(release);
    window: pointer = nil): Webview {.cdecl, importc: "webview_create", webview.}
  ## Creates a new webview instance. If debug is non-zero - developer tools will
  ## be enabled (if the platform supports them). Window parameter can be a
  ## pointer to the native window handle. If it's non-null - then child WebView
  ## is embedded into the given parent window. Otherwise a new window is created.
  ## Depending on the platform, a `GtkWindow`, `NSWindow` or `HWND` pointer can be
  ## passed here. Returns null on failure. Creation can fail for various reasons
  ## such as when required runtime dependencies are missing or when window creation
  ## fails.

proc destroy*(w: Webview) {.cdecl, importc: "webview_destroy", webview.}
  ## Destroys a webview and closes the native window.

proc run*(w: Webview) {.cdecl, importc: "webview_run", webview.}
  ## Runs the main loop until it's terminated. After this function exits - you
  ## must destroy the webview.

proc terminate*(w: Webview) {.cdecl, importc: "webview_terminate", webview.}
  ## Stops the main loop. It is safe to call this function from another other
  ## background thread.

proc dispatch*(w: Webview; fn: proc (w: Webview; arg: pointer) {.cdecl.};
                     arg: pointer = nil) {.cdecl, importc: "webview_dispatch",
                     webview.}
  ## Posts a function to be executed on the main thread. You normally do not need
  ## to call this function, unless you want to tweak the native window.

proc getWindow*(w: Webview): pointer {.cdecl, importc: "webview_get_window",
                                      webview.}
  ## Returns a native window handle pointer. When using GTK backend the pointer
  ## is `GtkWindow` pointer, when using Cocoa backend the pointer is `NSWindow`
  ## pointer, when using Win32 backend the pointer is `HWND` pointer.

proc setTitle*(w: Webview; title: cstring) {.cdecl,
    importc: "webview_set_title", webview.}
  ## Updates the title of the native window. Must be called from the UI thread.

const
  # Window size hints

  WEBVIEW_HINT_NONE*  = 0 ## Width and height are default size
  WEBVIEW_HINT_MIN*   = 1 ## Width and height are minimum bounds
  WEBVIEW_HINT_MAX*   = 2 ## Width and height are maximum bounds
  WEBVIEW_HINT_FIXED* = 3 ## Window size can not be changed by a user

proc setSize*(w: Webview; width: cint; height: cint;
    hints: cint = WEBVIEW_HINT_NONE) {.cdecl,
    importc: "webview_set_size", webview.}
  ## Updates native window size. See WEBVIEW_HINT constants.

proc navigate*(w: Webview; url: cstring) {.cdecl,
    importc: "webview_navigate", webview.} =
  ## Navigates webview to the given URL. URL may be a properly encoded data URI.

  runnableExamples:
    let w = create()

    w.navigate("https://github.com/webview/webview")
    w.navigate("data:text/html,%3Ch1%3EHello%3C%2Fh1%3E")
    w.navigate("data:text/html;base64,PGgxPkhlbGxvPC9oMT4=")

proc setHtml*(w: Webview; html: cstring) {.cdecl,
    importc: "webview_set_html", webview.} =
  ## Set webview HTML directly.

  runnableExamples:
    let w = create()

    w.setHtml("<h1>Hello</h1>")

proc init*(w: Webview; js: cstring) {.cdecl, importc: "webview_init", webview.}
  ## Injects JavaScript code at the initialization of the new page. Every time
  ## the webview will open a the new page - this initialization code will be
  ## executed. It is guaranteed that code is executed before window.onload.

proc eval*(w: Webview; js: cstring) {.cdecl, importc: "webview_eval", webview.}
  ## Evaluates arbitrary JavaScript code. Evaluation happens asynchronously, also
  ## the result of the expression is ignored. Use RPC bindings if you want to
  ## receive notifications about the results of the evaluation.

proc webviewBind*(w: Webview; name: cstring;
                 fn: proc (seq: cstring; req: cstring; arg: pointer) {.cdecl.};
                 arg: pointer = nil) {.cdecl, importc: "webview_bind", webview.}
  ## Binds a callback so that it will appear under the given name as a
  ## global JavaScript function. Internally it uses `init()`. Callback
  ## receives a request string and a user-provided argument pointer. Request
  ## string is a JSON array of all the arguments passed to the JavaScript
  ## function.

proc unbind*(w: Webview; name: cstring) {.cdecl,
                                importc: "webview_unbind", webview.}
  ## Removes a callback that was previously set by `bindCallback()`.

proc webviewReturn*(w: Webview; seq: cstring; status: cint;
    result: cstring) {.cdecl, importc: "webview_return", webview.}
  ## Allows to return a value from the native binding. Original request pointer
  ## must be provided to help internal RPC engine match requests with responses.
  ##
  ## If status is zero - result is expected to be a valid JSON result value.
  ##
  ## If status is not zero - result is an error JSON object.

proc webviewVersion*(): ptr WebviewVersionInfo {.cdecl,
    importc: "webview_version", webview.}
  ## Get the library's version information.

# -------------------

type
  WebviewHint* = enum
    ## Enum version of WEBVIEW_HINT consts.

    HintNone  ## Width and height are default size
    HintMin   ## Width and height are minimum bounds
    HintMax   ## Width and height are maximum bounds
    HintFixed ## Window size can not be changed by a user

  CallBackContext = ref object
    w: Webview
    fn: proc (seq: string; req: JsonNode): JsonNode

proc version*(): WebviewVersionInfo = webviewVersion()[]
  ## Dereferenced of `webviewVersion()`.
  ##
  ## Same as `webviewVersion()[]`.

proc bindCallback*(w: Webview; name: string;
                 fn: proc (seq: string; req: JsonNode): JsonNode) =
  ## Essentially a high-level version of `webviewBind`

  proc closure(seq: cstring; req: cstring; arg: pointer) {.cdecl.} =
    var err: cint
    let ctx = cast[CallBackContext](arg)

    let res = try:
      ctx.fn($seq, parseJson($req))
    except:
      err = -1
      %* getCurrentExceptionMsg()

    webviewReturn(ctx.w, seq, err, cstring $res)

  var arg = CallBackContext(w: w, fn: fn)
  GC_ref arg

  w.webviewBind(name, closure, cast[pointer](arg))

  GC_unref arg

proc setSize*(w: Webview; width: int; height: int;
    hints: WebviewHint = HintNone) =
  w.setSize(cint width, cint height, cint ord(hints))

proc `html=`*(w: Webview; html: string) =
  ## Setter alias for `setHtml()`.

  runnableExamples:
    let w = create()

    w.html = "<h1>Hello</h1>"

  w.setHtml(html)

proc `size=`*(w: Webview; size: tuple[width: int; height: int]) =
  ## Setter alias for `setSize()`. `hints` default to `WEBVIEW_HINT_NONE`.

  w.setSize(cint size.width, cint size.height, WEBVIEW_HINT_NONE)

proc `title=`*(w: Webview; title: string) =
  ## Setter alias for `setTitle()`.

  w.setTitle(title)

proc newWebview*(debug: bool = not defined(release);
    window: pointer = nil): Webview =
  ## Alias of `create()`

  create(cint debug, window)
