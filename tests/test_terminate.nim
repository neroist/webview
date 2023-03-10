import std/unittest

import "webview.nim"


test "start app loop and terminate it.":
  let w = create()

  w.dispatch() do (web: Webview; _: pointer) {.cdecl.}:
    web.terminate()

  w.run()
  w.destroy()