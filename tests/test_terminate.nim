import std/unittest

import "webview.nim"

let w = create()

test "start app loop and terminate it.":
  w.dispatch() do (web: Webview; _: pointer) {.cdecl.}:
    web.terminate()

  w.run()
  w.destroy()