## Script to install Webview2 SDK for Windows

import std/os

createDir("libs/webview2")

discard execShellCmd"curl -sSL https://www.nuget.org/api/v2/package/Microsoft.Web.WebView2 | tar -xf - -C libs/webview2"
