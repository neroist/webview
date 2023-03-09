import std/unittest
import std/strutils

import "webview.nim"

test "version()":
  let ver = version()

  check ver.version.major == WEBVIEW_VERSION_MAJOR
  check ver.version.minor == WEBVIEW_VERSION_MINOR
  check ver.version.patch == WEBVIEW_VERSION_PATCH
  check ver.versionNumber.join().replace("\0", "") == WEBVIEW_VERSION_NUMBER
  check ver.versionNumber.join().replace("\0", "") == WEBVIEW_VERSION_NUMBER
  check ver.versionNumber.join().replace("\0", "") == WEBVIEW_VERSION_NUMBER