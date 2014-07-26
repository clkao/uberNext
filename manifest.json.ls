manifest_version: 2
name: 'uberNext'
description: 'Alert when uber vehicles become available'
version: '0.3.2'
#background: scripts: <[background.js]>
permissions: <[
  https://m.uber.com/*
  https://api.uber.com/*
  notifications
  tabs
  storage
  tts
  geolocation
  webRequest
  webRequestBlocking
  ]>
browser_action:
  default_icon: "ubernext-128.png"
  default_title: "uberNext"
  default_popup: "index.html"
background:
  scripts: <[jquery.min.js angular.js background.js]>
content_scripts: [
  matches: [
    'https://m.uber.com/*'
  ]
  js: <[
    jquery.min.js
    oauth.js
    contentscript.js
  ]>
  css: <[styles.css]>
  run_at: 'document_idle'
  all_frames: true
]
web_accessible_resources: <[bell.wav ubernext-128.png]>
externally_connectable:
  matches: <[https://oauth.io/* http://localhost:6284/*]>
content_security_policy: "script-src 'self' 'unsafe-eval' http://localhost:6284; object-src 'self'"
icons:
  48: 'ubernext-48.png'
  128: 'ubernext-128.png'
