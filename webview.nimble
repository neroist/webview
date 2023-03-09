import os

# Package

version       = "0.1.0"
author        = "Jasmine"
description   = "Webview bindings for Nim"
license       = "MIT"
installFiles  = @["webview.nim"]
installDirs   = @["libs"]


# Tasks

task installSDK, "Install WebView2 SDK for Windows":
  mkDir "libs\\webview2"
  # exec doesnt work??????
  discard gorgeEx "curl -sSL https://www.nuget.org/api/v2/package/Microsoft.Web.WebView2 | tar -xf - -C libs\\webview2"

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
