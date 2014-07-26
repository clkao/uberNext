console.dir 'init uberNext', $

<- $
var checking
threshold = 15
console.dir 'init uberNext', $


icon = chrome.extension.getURL "ubernext-128.png"
unext = $('<img />').attr \src icon .appendTo ('.logo')

src = chrome.extension.getURL "bell.wav"

$ """<audio id="uber-next-sound"><source src="#{src}"></source></audio>""" .appendTo 'body'

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
    n.onclick = ->
      window.focus!
      $ '.set' .trigger 'click'
    $ '#uber-next-sound' .0.play!
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
