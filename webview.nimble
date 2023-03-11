# Package

version       = "0.2.3"
author        = "Jasmine"
description   = "Webview bindings for Nim"
license       = "MIT"
installFiles  = @["webview.nim"]
installDirs   = @["libs", "webview"]


# Tasks

task installSDK, "Install WebView2 SDK for Windows":
  echo "\nInstalling Webview2 SDK..."
  
  discard gorgeEx "nim c -r webview/instsdk.nim"

after install:
  when defined(windows):
    installSDKTask()

when defined(nimdistros) and not (defined(macos) or defined(macosx) or defined(windows)):
  import std/distros

  let debianBased = detectOs(Ubuntu) or detectOs(Elementary) or detectOs(Debian) or 
      detectOs(KNOPPIX) or detectOs(SteamOS) or detectOs(Zorin) or detectOs(Parrot) or
      detectOs(Kali)

  let fedoraBased = detectOs(Fedora) or detectOs(Qubes) or detectOs(ClearOS) or
      detectOs(RedHat) or detectOs(Scientific) or detectOs(Oracle) or detectOs(Korora)

  let bsd = defined(bsd)

  if debianBased:
    foreignDep "libgtk-3-dev"
    foreignDep "libwebkit2gtk-4.0-dev"
  elif fedoraBased:
    foreignDep "gtk3-devel"
    foreignDep "webkit2gtk4.0-devel"
  elif bsd:
    foreignDep "webkit2-gtk3"

  echo ""

  echo "This package requires some external dependencies."
  echo "To install them you may be able to run:\n"

  echoForeignDeps()

# Dependencies

requires "nim >= 1.0.0"
