import std/unittest
import std/json

import webview

test "test synchronous binding and unbinding. (low-level)":
  var number: int

  let w = newWebview()

  proc test(seq: cstring, req: cstring, arg: pointer) {.cdecl.} =
    proc increment(_: cstring, _: cstring, _: pointer) {.cdecl.} = 
      inc number

    # Bind and increment number.
    if req == "[0]":
      check number == 0
      w.webviewBind("increment", increment)

      w.eval "(() => {try{window.increment()}catch{}window.test(1)})()"

    # Unbind and make sure that we cannot increment even if we try.
    if req == "[1]":
      check number == 1
      w.unbind("increment")

      w.eval "(() => {try{window.increment()}catch{}window.test(2)})()"

    # Number should not have changed but we can bind again and change the number.
    if req == "[2]":
      check number == 1
      w.webviewBind("increment", increment)

      w.eval "(() => {try{window.increment()}catch{}window.test(3)})()"

    # finish test
    if req == "[3]":
      check number == 2
      
      w.terminate()

  const html = """
  <script>
    window.test(0);
  </script>
  """

  # Attempting to remove non-existing binding is OK
  w.unbind("test")
  w.webviewBind("test", test)

  # Attempting to bind multiple times only binds once
  w.webviewBind("test", test)
  
  w.setHtml(html)

  w.run()
  w.destroy()

test "test synchronous binding and unbinding. (high-level)":
  var number: int

  let w = newWebview()

  proc test(_: string, req: JsonNode): string =
    proc increment(_: string, _: JsonNode): string = 
      inc number
    
    let arg = req[0].getInt()

    case arg
    of 0:
      # Bind and increment number.
      check number == 0
      w.bind("increment", increment)

      w.eval "(() => {try{window.increment()}catch{}window.test(1)})()"
    of 1:
      # Unbind and make sure that we cannot increment even if we try.
      check number == 1
      w.unbind("increment")

      w.eval "(() => {try{window.increment()}catch{}window.test(2)})()"
    of 2:
      # Number should not have changed but we can bind again and change the number.
      check number == 1
      w.bind("increment", increment)

      w.eval "(() => {try{window.increment()}catch{}window.test(3)})()"
    else: # will be 3
      # finish test
      check number == 2
      w.terminate()

    return

  const html = """
  <script>
    window.test(0);
  </script>
  """

  # Attempting to remove non-existing binding is OK
  w.unbind("test")
  w.bind("test", test)

  # Attempting to bind multiple times only binds once
  w.bind("test", test)
  
  w.html = html
  
  w.run()
  w.destroy()
