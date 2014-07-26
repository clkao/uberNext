console.dir 'init uberNext', $

<- $
var checking
threshold = 15
console.dir 'init uberNext', $

src = chrome.extension.getURL("bell.wav"); 

$ """<audio id="uber-next-sound"><source src="#{src}"></source></audio>""" .appendTo 'body'

check = ->
  x = $ '.eta strong' .text! |> parseInt
  if  x <= threshold
    icon = $('.slider img').attr 'src'
    [_, type]? = icon.match /mono-(\w+)\.png/
    n = new Notification "uberNext",
      body: "uber #{type || '(unknown)'} in #{x}"
      icon: icon
    n.onclick = ->
      window.focus!
      $ '.set' .trigger 'click'
    $ '#uber-next-sound' .0.play!
  else 
    checking := setTimeout check, 10 * 1000ms

$ '.logo' .click ->
  console.dir 'clicky'
  status <- Notification.requestPermission
  console.dir status
  n = new Notification "uberNext", body: "init"
  check!
