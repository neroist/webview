import std/unittest
import std/json

import ../webview

test "test synchronous binding and unbinding. (low-level)":
  var number: int

  let w = newWebview(false)

  proc test(seq: cstring, req: cstring, arg: pointer) {.cdecl.} =
    proc increment(s: cstring, _: cstring, aarg: pointer) {.cdecl.} = 
      inc number

    # Bind and increment number.
    if req == "[0]":
      check number == 0
      w.webviewBind("increment", increment)

      w.webviewReturn seq, 1, "(() => {try{window.increment()}catch{}window.test(2)})()"

    # Unbind and make sure that we cannot increment even if we try.
    if req == "[1]":
      check number == 1
      w.unbind("increment")

      w.webviewReturn seq, 1, "(() => {try{window.increment()}catch{}window.test(2)})()"

    # Number should not have changed but we can bind again and change the number.
    if req == "[2]":
      check number == 1
      w.webviewBind("increment", increment)

      w.webviewReturn seq, 1, "(() => {try{window.increment()}catch{}window.test(3)})()"

    # finish test
    if req == "[3]":
      check number == 2
      w.terminate()

      return

  let html = """
  <script>
    window.test(0);
  </script>
  """

  # Attempting to remove non-existing binding is OK
  w.unbind("test")
  w.webviewBind("test", test)

  # Attempting to bind multiple times only binds once
  w.webviewBind("test", test)
  
  w.setHtml(cstring html)
  w.run()
  w.destroy()

test "test synchronous binding and unbinding. (high-level)":
  var number: int

  let w = newWebview(false)

  proc test(seq: string, req: JsonNode): string =
    proc increment(s: string, _: JsonNode): string = 
      inc number

    # Bind and increment number.
    if req == %* [0]:
      check number == 0
      w.bindCallback("increment", increment)

      return  "(() => {try{window.increment()}catch{}window.test(2)})()"

    # Unbind and make sure that we cannot increment even if we try.
    if req == %* [1]:
      check number == 1
      w.unbind("increment")
      echo "hi"

      return  "(() => {try{window.increment()}catch{}window.test(2)})()"

    # Number should not have changed but we can bind again and change the number.
    if req == %* [2]:
      check number == 1
      w.bindCallback("increment", increment)

      return  "(() => {try{window.increment()}catch{}window.test(3)})()"

    # finish test
    if req == %* [3]:
      check number == 2
      w.terminate()

      return

  let html = """
  <script>
    window.test(0);
  </script>
  """

  # Attempting to remove non-existing binding is OK
  w.unbind("test")
  w.bindCallback("test", test)

  # Attempting to bind multiple times only binds once
  w.bindCallback("test", test)
  
  w.setHtml(cstring html)
  w.run()
  w.destroy()
