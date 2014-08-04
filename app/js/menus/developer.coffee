gui = window.require('nw.gui')
win = gui.Window.get()


developer = new gui.Menu()
developer.append new gui.MenuItem(
  label: "Open Developer Tools"
  click: ->
    win.showDevTools()
    return

  key: "i"
  modifiers: "shift-cmd"
)
# developer.append new gui.MenuItem(
#   label: "Reload Aries"
#   click: ->
#     win.reload()
#     console.log "Reloaded Aries"
#     return

#   key: "r"
#   modifiers: "shift-cmd"
# )

module.exports = developer