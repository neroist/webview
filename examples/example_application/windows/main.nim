import webview

{.link: "build/resources.o".}

proc main = 
  let w = newWebview()

  w.title = "Youtube"
  w.size = (800, 800)

  w.navigate("https://www.youtube.com")

  w.run()
  w.destroy()

main()
