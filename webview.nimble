# Package

version       = "0.1.0"
author        = "Jasmine"
description   = "Webview bindings for Nim"
license       = "MIT"
installFiles  = @["webview.nim"]
installDirs   = @["libs"]


# Tasks

task installSDK, "Install WebView2 SDK for Windows":
  discard gorgeEx "nim c -r instsdk.nim"

after install:
  when defined(windows):
    installSDKTask()

when defined(nimdistros):
  import distros

  if detectOs(Debian):
    foreignDep "libgtk-3-dev"
    foreignDep "libwebkit2gtk-4.0-dev"
  elif detectOs(Fedora):
    foreignDep "gtk3-devel"
    foreignDep "webkit2gtk4.0-devel"
  elif detectOs(BSD):
    foreignDep "webkit2-gtk3"
  else:
    discard


# Dependencies

requires "nim >= 1.0.0"
