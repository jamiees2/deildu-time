gui = window.require('nw.gui')
win = gui.Window.get()

help = new gui.Menu()
help.append new gui.MenuItem(
  label: "Deildu Time Help"
  click: ->
    console.log "Clicked 'Deildu Time Help'"
    return
)
help.append new gui.MenuItem(
  label: "Keyboard Shortcuts"
  click: ->
    console.log "Clicked 'Keyboard Shortcuts'"
    return
)
help.append new gui.MenuItem(type: "separator")
help.append new gui.MenuItem(
  label: "Report Issues"
  click: ->
    console.log "Clicked 'Report Issues'"
    return
)

module.exports = help