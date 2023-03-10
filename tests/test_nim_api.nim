import std/unittest

import webview

test "create a window, run app and terminate it.":
  proc cbAssertArg(w: Webview, arg: pointer) {.cdecl.} = 
    check w != nil
    check cast[string](arg) == "arg"

  proc cbTerminate(w: Webview, arg: pointer) {.cdecl.} = 
    check arg == nil
    w.terminate()

  let w = newWebview()
  
  w.setSize(280, 320, WEBVIEW_HINT_NONE)
  w.setTitle("Test")
  
  w.navigate("https://github.com/zserge/webview")
  w.dispatch(cbAssertArg, cast[pointer]("arg"))
  w.dispatch(cbTerminate, nil)

  w.run()
  w.destroy()
