import std/json

import webview

const html = """
<button id="increment">Tap me</button>
<div>You tapped <span id="count">0</span> time(s).</div>
<script>
  const [incrementElement, countElement] =
    document.querySelectorAll("#increment, #count");
  document.addEventListener("DOMContentLoaded", () => {
    incrementElement.addEventListener("click", () => {
      window.increment().then(result => {
        countElement.textContent = result.count;
      });
    });
  });
</script>
"""

proc main =
  let w = create()

  var count: int

  if w == nil:
    echo "Failed to create webview."
    quit 1

  w.title = "Bind Example"
  w.size = (480, 320)

  w.bindCallback("increment") do (seq: string; req: JsonNode) -> string:
    inc count

    return $ %* {"count": count}

  w.html = html

  w.run()
  w.destroy()  

main()
