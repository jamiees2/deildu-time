gui = window.require('nw.gui')
win = gui.Window.get()

file = new gui.Menu()
file.append new gui.MenuItem(
  label: "Options"
  click: ->
    console.log "Clicked 'Options'"
    App.vent.trigger 'open:options'
    return

  key: ","
  modifiers: "cmd"
)
file.append new gui.MenuItem(type: "separator")
file.append new gui.MenuItem(
  label: "Clean Downloads"
  click: ->
    console.log "Clicked 'Clean Downloads'"
    App.vent.trigger 'downloads:clean'
    return
)
file.append new gui.MenuItem(
  label: "Open Developer Tools"
  click: ->
    win.showDevTools()
    return

  key: "i"
  modifiers: "shift-cmd"
)

module.exports = file