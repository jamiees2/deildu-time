gui = window.require('nw.gui')
win = gui.Window.get()

edit = new gui.Menu()
edit.append new gui.MenuItem(
  label: "Cut"
  click: ->
    document.execCommand "cut"
    console.log "Cut something"
    return

  key: "x"
  modifiers: "cmd"
)
edit.append new gui.MenuItem(
  label: "Copy"
  click: ->
    document.execCommand "copy"
    console.log "Copied something"
    return

  key: "c"
  modifiers: "cmd"
)
edit.append new gui.MenuItem(
  label: "Paste"
  click: ->
    document.execCommand "paste"
    console.log "Pasted something"
    return

  key: "v"
  modifiers: "cmd"
)

module.exports = edit