gui = window.require('nw.gui')
win = gui.Window.get()

file = new gui.Menu()
file.append new gui.MenuItem(
  label: "New Tab"
  click: ->
    console.log "Clicked 'New Tab'"
    return

  key: "t"
  modifiers: "cmd"
)
module.exports = file