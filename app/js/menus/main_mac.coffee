gui = window.require('nw.gui')
win = gui.Window.get()

menu = new gui.Menu()
menu.append new gui.MenuItem(
  label: "About Deildu Time"
  click: ->
    console.log "Clicked 'About Deildu Time'"
    App.vent.trigger 'open:about'
    return
)
menu.append new gui.MenuItem(type: "separator")
menu.append new gui.MenuItem(
  label: "Preferences"
  click: ->
    console.log "Clicked 'Preferences'"
    App.vent.trigger 'open:options'
    return

  key: ","
  modifiers: "cmd"
)
menu.append new gui.MenuItem(type: "separator")
menu.append new gui.MenuItem(
  label: "Clean Downloads"
  click: ->
    console.log "Clicked 'Clean Downloads'"
    return
)
menu.append new gui.MenuItem(
  label: "Open Developer Tools"
  click: ->
    win.showDevTools()
    return

  key: "i"
  modifiers: "shift-cmd"
)
menu.append new gui.MenuItem(type: "separator")
menu.append new gui.MenuItem(
  label: "Hide Deildu Time"
  click: ->
    win.minimize()
    return

  key: "h"
  modifiers: "cmd"
)
# menu.append new gui.MenuItem(
#   label: "Hide Others"
#   click: ->
#     console.log "Clicked 'Hide Others'"
#     return

#   key: "h"
#   modifiers: "shift-cmd"
# )
# menu.append new gui.MenuItem(
#   label: "Show All"
#   click: ->
#     console.log "Clicked 'Show All'"
#     return
# )
menu.append new gui.MenuItem(type: "separator")
menu.append new gui.MenuItem(
  label: "Quit Deildu Time"
  click: ->
    win.close()
    console.log "Clicked 'Quit Deildu Time'"
    return

  key: "q"
  modifiers: "cmd"
)

module.exports = menu