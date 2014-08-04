gui = global.window.nwDispatcher.requireNwGui()


menubar = new gui.Menu(type: "menubar")
if process.platform is "darwin"
    menubar.createMacBuiltin("Deildu Time");
    require('./main_mac')(menubar.items[0].submenu)
    # menubar.append new gui.MenuItem(
    # 	label: "Help"
    # 	submenu: require('./help')
    # )
else
	menubar.append new gui.MenuItem(
		label: "File"
		submenu: require('./file')
	)
gui.Window.get().menu = menubar
  # _iframe = ""
  # _iframe += "<iframe class='tabs-pane active'"
  # _iframe += "seamless='true'"
  # _iframe += "nwUserAgent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.113 Aries/0.2-alpha'"
  # _iframe += "nwdisable nwfaketop "
  # _iframe += "onLoad='pageLoad();'"
  # _iframe += "id='tab1'>"
  # $("#aries-showcase").append _iframe
  # $(".app-minimize").on "click", ->
  #   win.minimize()
  #   return

  # $(".app-maximize").on "click", ->
  #   win.maximize()
  #   return

  # $(".app-close").on "click", ->
  #   win.close()
  #   return

