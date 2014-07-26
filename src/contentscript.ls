<- $
var checking
threshold = 15
console.dir 'init uberNext', $

v-check = ->
  id = $ '.vehicle-selector li.shift' .data \id
  n = $ 'div#map img[src*="car-types"]' .length
  [_, latitude, longitude]? = $ '#map a[href*="maps?ll="]' .attr('href')?match /ll=([-\d.]+),([-\d.]+)/
  address = $ 'div.map-view p.pickup-location span' .text!
  [id, n, latitude, longitude, address]

unless window.top == window
  port = chrome.runtime.connect({name: "uberNext"});
  port.postMessage type: "init"
  post = ->
    [id, n, latitude, longitude, address] = v-check!
    port.postMessage {type: "update", id, n, latitude, longitude, address} if id
    set-timeout post, 2000ms

  post!
  port.onMessage.addListener (msg) ->

icon = chrome.extension.getURL "ubernext-128.png"
unext = $('<img />').attr \src icon .appendTo ('.logo')

check = ->
  x = $ '.eta strong' .text! |> parseInt
  if  x <= threshold
    icon = $('.slider img').attr 'src'
    [_, type]? = icon.match /mono-(\w+)\.png/
    unext.removeClass 'active'
    checking := null
    n = new Notification "uberNext",
      body: "uber #{type || '(unknown)'} in #{x}"
      icon: icon
    new Audio chrome.extension.getURL "bell.wav" .play!
    n.onclick = ->
      window.focus!
      $ '.set' .trigger 'click'
  else 
    checking := setTimeout check, 10 * 1000ms

unext.click ->
  if checking
    clearTimeout checking
    unext.removeClass 'active'
    checking := null
    return
  status <- Notification.requestPermission
  console.dir status
  n = new Notification "uberNext", body: "init"
  unext.addClass 'active'
  check!
