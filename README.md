# Webview

Updated bindings for [Webview](https://github.com/webview/webview) for Nim than [oskca's
bindings](https://github.com/oskca/webview), which were last updated 5 years ago and are
severely out of date.

## Documentation

Documentation is available at
https://neroist.github.io/webview/

## Installation

Install via Nimble:

```
nimble install https://github.com/neroist/webview
```

This package isn't available via Nimble's package
list, so you have to install via GitHub link.

## Requirements

On Windows, Webview requires that developers and end-users must have the [WebView2
runtime](https://developer.microsoft.com/en-us/microsoft-edge/webview2/) installed on their system for any version of Windows before Windows 11. The WebView2 SDK is
installed for you, so no need to worry about that.

On Linux and BSD, Only [GTK3](https://docs.gtk.org/gtk3/) and 
[WebKitGTK](https://webkitgtk.org/) are required for development and distribution.
See [here](https://github.com/webview/webview#linux-and-bsd).

## Distribution

See [here](https://github.com/webview/webview#app-distribution) in Webview's README.