import std/unittest

import webview

test "start app loop and terminate it.":
  let w = newWebview()

  w.dispatch() do (web: Webview; _: pointer) {.cdecl.}:
    web.terminate()

  w.run()
  w.destroy()