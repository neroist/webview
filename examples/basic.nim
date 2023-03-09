import ../webview

let w = create()

w.title = "Basic Example"
w.size = (480, 320)
w.html = "Thanks for using webview!"

w.run()
w.destroy()
