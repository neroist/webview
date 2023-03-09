import std/os

echo "\nInstalling Webview2 SDK..."

createDir("libs/webview2")

discard execShellCmd"curl -sSL https://www.nuget.org/api/v2/package/Microsoft.Web.WebView2 | tar -xf - -C libs\\webview2"