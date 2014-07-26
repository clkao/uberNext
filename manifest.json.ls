manifest_version: 2
name: 'uberNext'
description: 'Alert when uber vehicles become available'
version: '0.3.2'
#background: scripts: <[background.js]>
permissions:
  * 'https://m.uber.com/*'
  * \tabs
  * \storage
content_scripts: [
  matches: [
    'https://m.uber.com/*'
  ]
  js: [
    'jquery.min.js'
    'contentscript.js'
  ]
  css: <[styles.css]>
  run_at: 'document_idle'
  all_frames: true
]
web_accessible_resources: <[bell.wav ubernext-128.png]>
icons:
  48: 'ubernext-48.png'
  128: 'ubernext-128.png'
