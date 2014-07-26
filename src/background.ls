do
  info <- chrome.webRequest.onHeadersReceived.addListener _, {urls: [ '*://*/*' ] types: [ 'sub_frame' ] },
    ['blocking', 'responseHeaders']
  headers = info.responseHeaders
  for header, i in headers => let h = header.name.toLowerCase!
    if h == 'x-frame-options' || h == 'frame-options'
      headers.splice i, 1
  return responseHeaders: headers

angular.module 'uberNextBg' <[]>
.run <[$rootScope $http $q]> ++ ($rootScope, $http, $q) ->
  hasTokens = $q.defer!
  hasProducts = $q.defer!
  productLocation = {}
  $rootScope.$watch 'tokens' ->
    $http.defaults.headers.common.Authorization = it<[token_type access_token]>.join ' '
    hasTokens.resolve it if it

  var unwatch
  $rootScope.init = ->
  $rootScope.initpopup = (_, port) ->
    $rootScope.popup = port
    port.postMessage {type: 'init', monitor: !!unwatch} <<< $rootScope{latitude, longitude, address}
    if unwatch
      $rootScope.popup.postMessage {type: 'products', $rootScope.products}
  $rootScope.setTokens = ({tokens}) ->
    local-storage.tokens = JSON.stringify tokens
    $rootScope.tokens = tokens
  $rootScope.update = ({latitude, longitude, address, id, n}) ->
    $rootScope <<< {latitude, longitude, address}
  $rootScope.setLocation = ({latitude, longitude}:msg) ->
    $rootScope <<< {latitude, longitude}
    productLocation <<< {latitude, longitude}
    <- hasTokens.promise.then
    {products}? <- $http.get 'https://api.uber.com/v1/products' params: $rootScope{latitude,longitude}
    .success
    $rootScope.products = {[product_id, product] for {product_id}:product in products}
    $rootScope.popup.postMessage {type: 'products', $rootScope.products}
    hasProducts.resolve!
    $rootScope.estimates = {}
    once = $rootScope.$watch 'address' -> if it
      console.log "address" $rootScope.address
      $rootScope.popup?postMessage {type: 'address', $rootScope.address}
      once!

  var cancel
  docheck = ->
    <- hasProducts.promise.then
    {times} <- $http.get 'https://api.uber.com/v1/estimates/time', params: $rootScope{start_latitude: latitude, start_longitude: longitude}
    .success
    for _, e of $rootScope.estimates
      delete e.time
      delete e.eta
    now = new Date!getTime!
    for {product_id, estimate} in times
      $rootScope.estimates[product_id] ?= {}
      $rootScope.estimates[product_id] <<< {time: estimate, eta: now + estimate * 1000ms}
    $rootScope.popup?postMessage {type: 'estimates', $rootScope.estimates}

  $rootScope.$watchGroup <[latitude longitude]> ->
    return unless $rootScope.latitude
    if (productLocation.latitude - $rootScope.latitude)**2 + (productLocation.longitude - $rootScope.longitude)**2 > 1
      clear-timeout cancel if cancel
      $rootScope.setLocation $rootScope{latitude,longitude}
    else
      docheck!

  var activeNotification
  #chrome.tts.speak("Your uber arrives in 5 minutes.")
  nserial = 0
  chrome.notifications.onClicked.addListener (id) ->
    if $rootScope.popup
      console.log \notifypopupstate
      #$rootScope.popup.postMessage type: 'go'
    else
      chrome.tabs.create url : "index.html"

  chrome.notifications.onButtonClicked.addListener (id, idx) ->
    console.log \clicked id, idx

  chrome.notifications.onClosed.addListener (id) ->
    console.log \closed? id

  $rootScope.monitor = ({departure, buffer, selected})->
    unwatch?!
    unwatch := $rootScope.$watch 'estimates' (->
      now = new Date!getTime!
      wanted = []
      leaving = Math.round (departure - now) / 1000ms / 60s
      chrome.browserAction.setBadgeText text: "#{leaving}m"
      chrome.browserAction.setBadgeBackgroundColor "color": '#0f9d58'
      for product_id, {eta,time} of $rootScope.estimates when selected[product_id]
        offset = departure - eta
        if 0 <= offset <= buffer * 60s * 1000ms
          wanted.push {offset, eta, time, product_id}
      return unless wanted.length
      buttons = wanted.map ({product_id, eta, time}) ->
        title: $rootScope.products[product_id].display_name + ' ' + Math.round(time/60)+'m'+(time%60)+'s'

      # XXX sort
      console.log \wanted wanted
      opts = do
        type: "basic"
        title: "uberNext"
        iconUrl: chrome.extension.getURL "ubernext-128.png"
        message: "Uber available"
        buttons: buttons
        eventTime: 1000
        isClickable: true
      notification = ->
        id <- chrome.notifications.create "uberNext-#{++nserial}" opts
        activeNotification := id
      if activeNotification
        updated <- chrome.notifications.update activeNotification, opts
        notification! unless updated
      else
        notification!
        new Audio chrome.extension.getURL "bell.wav" .play!
    ), true
    $rootScope.check!

  $rootScope.check = ->
    clear-timeout cancel if cancel
    doit = ->
      docheck!
      cancel := set-timeout doit, 5000ms
    doit!

  if local-storage.tokens
    $rootScope.tokens = try JSON.parse that

  chrome.runtime.onConnect.addListener (port) ->
    $rootScope.port = port
    console.assert port.name is "uberNext"
    port.onMessage.addListener ({type}:msg) ->
      $rootScope.$apply -> $rootScope?[type]? msg, port
    port.onDisconnect.addListener ({type}:msg) ->
      if $rootScope.popup is port
        delete $rootScope.popup

<- $ document .ready
$html = $ 'html'
$html.addClass 'ng-app' .addClass 'ng-csp'

angular.bootstrap $html, ['uberNextBg']
