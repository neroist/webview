import ../webview

let w = newWebview() # or you can use create()

w.title = "Basic Example"
w.size = (480, 320)
w.html = "Thanks for using webview!"

w.run()
w.destroy()
