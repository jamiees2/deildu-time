
gui = window.require('nw.gui')
win = gui.Window.get()

App.vent.on 'window:close', ->
    win.close()
App.vent.on 'window:close:force', ->
    win.close(true)

App.vent.on 'navigate', (target) ->
    App.views.menu.trigger 'navigate', target

App.vent.on 'torrent:add', (torrent) ->
    App.torrentlist.add({torrent: torrent})
    App.vent.trigger('navigate:torrentlist')

windows = {}
App.vent.on 'open:about', ->
    return if windows.about?
    windows.about = gui.Window.open("views/about.html",
      position: "center"
      width: 600
      height: 297
      frame: false
      toolbar: false
      focus: true
    )
    windows.about.setShowInTaskbar(true)
    windows.about.on 'closed', ->
        windows.about = null

App.vent.on 'open:options', ->
    return if windows.options?
    windows.options = gui.Window.open("views/options.html",
      position: "center"
      width: 600
      height: 297
      frame: false
      toolbar: false
      focus: true
    )
    windows.options.setShowInTaskbar(true)
    # windows.options.setAlwaysOnTop(true)
    windows.options.on 'closed', ->
        windows.options = null
