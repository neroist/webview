# Webview

Webview is a wrapper for [Webview](https://github.com/webview/webview), a tiny
cross-platform webview library for C/C++ to build modern cross-platform GUIs.
Webview (the wrapper) supports two-way JavaScript bindings, to call JavaScript from
Nim and to call Nim from JavaScript.

Webview is also an updated wrapper for [Webview](https://github.com/webview/webview)
for Nim than [oskca's bindings](https://github.com/oskca/webview), which were last
updated 5 years ago and are severely out of date.

## Binding Features

Similiar to [`uing`](https://github.com/neroist/uing), you can also choose to
whether or not compile with a DLL, static library, or to statically compile Webview
into your executable.

To compile with a DLL, pass `-d:useWebviewDll` to the Nim
compiler. To compile with a static library, compile with
`-d:useWebviewStaticLib` or `-d:useWebviewStaticLibrary`.

## Documentation

Documentation is available at <https://neroist.github.io/webview>

### Examples

Examples can be found at [`examples/`](examples/). Currently, it contains two
examples, `basic.nim`, a basic example of Webview, and `bind.nim`, an example of
calling Nim from Javascript with Webview. In addition, it also has an [example
application](examples/example_application) in the structure described
[here](https://github.com/webview/webview#app-distribution).

Here's [`basic.nim`](examples/basic.nim) for you:

```nim
import webview

let w = newWebview() # or you can use create()

w.title = "Basic Example" # or use setTitle()
w.size = (480, 320) # or setSize()
w.html = "Thanks for using webview!" # or setHtml()

w.run()
w.destroy()
```

## Installation

Install via Nimble:

```shell
nimble install https://github.com/neroist/webview
```

This package isn't in Nimble's package list, so you have to install via GitHub link.

## Requirements

On Windows, Webview requires that developers and end-users must have the
[WebView2 runtime](https://developer.microsoft.com/en-us/microsoft-edge/webview2/)
installed on their system for any version of Windows before Windows 11. The
WebView2 SDK is installed for you, so no need to worry about that.

On Linux and BSD, Only [GTK3](https://docs.gtk.org/gtk3/) and
[WebKitGTK](https://webkitgtk.org/) are required for both development and distribution.
See [here](https://github.com/webview/webview#linux-and-bsd).

## Distribution

See [here](https://github.com/webview/webview#app-distribution) in Webview's README.
