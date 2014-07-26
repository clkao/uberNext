OAuth.initialize 'yGqY1RUH0sQL4ZTL5TxbOfo3FF8'

port = chrome.runtime.connect({name: "uberNext"});
port.postMessage type: "initpopup"

angular.module 'uberNext' <[ngMaterial]>
.controller 'AppCtrl', <[$scope $http $sce $timeout $materialToast]> ++ ($scope, $http, $sce, $timeout, $materialToast) ->
  port.onMessage.addListener ({type}:msg) -> $scope.$apply -> match type
  | 'products' => $scope.products = msg.products
  | 'estimates' => $scope.estimates = msg.estimates
  | 'address' => $scope.pickup.address = msg.address
  | 'init' =>
    if msg.monitor
      $scope.pickup = msg{latitude,longitude,address}
      # XXX: todo
      #$scope.departure = msg{departure}
      #$scope.buffer = msg{buffer}
    else if local-storage.default-location
      $scope.pickup = try JSON.parse that
      port.postMessage {type: "setLocation"} <<< $scope.pickup{latitude,longitude}
    else
      position <- navigator.geolocation.getCurrentPosition _, (err) ->
        console.error err
      <- $scope.$apply
      $scope.pickup = position.coords{latitude,longitude}
      port.postMessage {type: "setLocation"} <<< $scope.pickup{latitude,longitude}
      unwatch = $scope.$watch 'pickup.address' -> if it
        $materialToast do
          controller: 'SetDefaultLocationCtrl',
          templateUrl: 'default-location-toast.html'
          duration: 15000,
          position: 'top fit'
          locals: {$scope.pickup}
        unwatch!
  else
    console.log \=== msg
  $scope.departure = new Date new Date!getTime! + 15m * 60s * 1000ms
  $scope.buffer = 10
  $scope.estimates = {}
  $scope.selected = {}

  $scope.formatTime = ->
    "#{Math.round it/60}m"
  $scope.trim = -> it - /^uber/i
  $scope.toggleSelection = -> $scope.selecting = $scope.selecting
  $scope.check = ->
    port.postMessage {type: 'check'}
  $scope.go = ->
    port.postMessage {type: 'monitor', departure: $scope.departure.getTime!} <<< $scope{buffer,selected}
  $scope.connect = ->
    e, r <- OAuth.popup "uber"
    tokens = r{token_type,access_token,expires_in}
    port.postMessage {type: 'setTokens', tokens}
    user <- r.me!done
    local-storage.profile = JSON.stringify user
    $scope.$apply ->
      $scope.profile = user

  $scope.$watch 'products' ->
    console.log \products it
    $scope.selected = {}
    for id, car of it
      $scope.selected[id] = true

  if local-storage.profile
    $scope.profile = try JSON.parse that

  expandLocation = (name, location) ->
    {["#{name}_#key", val] for key, val of location}
  $scope.$watchGroup <[profile pickup]> ->
    return unless $scope.pickup?latitude
    $scope.iframeSrc = $sce.trustAsResourceUrl 'https://m.uber.com/sign-up?'+ [["#k=#{v}"] for k, v of {
      client_id: 'xoJe5d3uhmHPiQa2J_3E3jCYTzA02eG-'
      product_id: 'bb693cd4-3366-4c48-9874-155de18a31f5'
      } <<< expandLocation 'pickup' $scope.pickup <<< expandLocation 'dropoff' $scope.dropoff
    ].join '&'


.controller 'SetDefaultLocationCtrl' <[$scope $hideToast pickup]> ++ ($scope, $hideToast, pickup) ->
  $scope.pickup = pickup
  $scope.set = ->
    local-storage.default-location = JSON.stringify $scope.pickup
    $hideToast!
  $scope.closeToast = ->
    $hideToast!
