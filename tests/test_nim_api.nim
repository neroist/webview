import std/unittest

import webview

test "create a window, run app and terminate it.":
  proc cbAssertArg(w: Webview, arg: pointer) {.cdecl.} = 
    check w != nil
    check cast[cstring](arg) == "arg"

  proc cbTerminate(w: Webview, arg: pointer) {.cdecl.} = 
    check arg == nil
    w.terminate()

  let w = newWebview()
  
  w.setSize(280, 320, WebviewHintNone)
  w.setTitle("Test")
  
  w.navigate("https://github.com/zserge/webview")
  w.dispatch(cbAssertArg, cast[pointer](cstring "arg"))
  w.dispatch(cbTerminate, nil)

  w.run()
  w.destroy()
