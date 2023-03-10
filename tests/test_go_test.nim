# See https://github.com/webview/webview/blob/master/webview_test.go

import std/unittest
import std/json

import ../webview

proc example() = 
  let w = newWebview(true)

  w.setTitle("Hello")

  w.bindCallback("noop") do (seq: string, req: JsonNode) -> string:
    echo "hello"
    return "\"hello\"" # need quotes so JS thinks its a string, not an identifier

  w.bindCallback("add") do (seq: string, req: JsonNode) -> string:
    return $(req[0].getInt() + req[1].getInt())

  w.bindCallback("quit") do (seq: string, req: JsonNode) -> string:
    w.terminate()

  w.setHtml():
    cstring """
    <!doctype html>
    <html>
      <body>hello</body>

      <script>
        window.onload = function() {
          document.body.innerText = `hello, ${navigator.userAgent}`;

          noop().then(function(res) {
            console.log('noop res', res);

            add(1, 2).then(function(res) {
              console.log('add res', res);
              quit();
            });

          });
        };
      </script>
    </html>
    """

  w.run()
  w.destroy()

test "Golang-like webview test":
  example()
