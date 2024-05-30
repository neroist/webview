# Package

version       = "0.4.0"
author        = "neroist"
description   = "Webview bindings for Nim"
license       = "MIT"
installFiles  = @["webview.nim"]
installDirs   = @["libs"]


# Tasks

task installSDK, "Install WebView2 SDK for Windows":
  echo "\nInstalling Webview2 SDK..."

  mkDir "libs/webview2"
  exec  "curl -sSL https://www.nuget.org/api/v2/package/Microsoft.Web.WebView2 | tar -xf - -C libs/webview2"

after install:
  when defined(windows):
    installSDKTask()

  elif defined(linux) or defined(bsd):
    echo ""
    echo "This package requires some external dependencies."
    echo ""
    echo "If you're on a Debian-based system, install"
    echo "    libgtk-3-dev"
    echo "    libwebkit2gtk-4.0-dev"
    echo "If you're on a Fedora-based system, install"
    echo "    gtk3-devel"
    echo "    webkit2gtk4.0-devel"
    echo "If you're using a BSD system, install"
    echo "    webkit2-gtk3"

# Dependencies

requires "nim >= 1.0.0"
