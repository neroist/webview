import std/strutils
import std/json
import std/os

import webview

const html = """
<!DOCTYPE html>
<html
<head></head>
<body>
<div>
  <button id="increment">+</button>
  <button id="decrement">−</button>
  <span>Counter: <span id="counterResult">0</span></span>
</div>
<hr />
<div>
  <button id="compute">Compute</button>
  <span>Result: <span id="computeResult">(not started)</span></span>
</div>
<script type="module">
  const getElements = ids => Object.assign({}, ...ids.map(
    id => ({ [id]: document.getElementById(id) })));
  const ui = getElements([
    "increment", "decrement", "counterResult", "compute",
    "computeResult"
  ]);
  ui.increment.addEventListener("click", async () => {
    ui.counterResult.textContent = await window.count(1);
  });
  ui.decrement.addEventListener("click", async () => {
    ui.counterResult.textContent = await window.count(-1);
  });
  ui.compute.addEventListener("click", async () => {
    ui.compute.disabled = true;
    ui.computeResult.textContent = "(pending)";
    ui.computeResult.textContent = await window.compute(6, 7);
    ui.compute.disabled = false;
  });
</script>
</body>
</html>
"""

proc threadFunc(res: var string) {.thread.} = 
  sleep 1000
  res = "42"

proc main =
  let w = newWebview()
  var count: int

  if w == nil:
    echo "Failed to create webview."
    quit 1

  w.title = "Bind Example"
  w.size = (480, 320)

  w.bind("count") do (_: string; req: JsonNode) -> string:
    let dir = req[0].getInt()
    inc count, dir

    return $count
  
  w.bind("compute") do (_: string; req: JsonNode) -> string:
    # TODO
    result = "42"

  w.html = html

  w.run()
  w.destroy()  

main()
