peerflix = require('peerflix')
fs = require('fs')
path = require('path')
address = require('network-address')
video = require('../lib/video')
nwgui = global.window.nwDispatcher.requireNwGui()
win = nwgui.Window.get()

key 'command+d, ctrl+d', ->
    win.showDevTools()


process.env['PATH'] += ";#{path.dirname(process.execPath)}" if process.platform is "win32"

App = global.App = new Backbone.Marionette.Application();

container = new Backbone.Marionette.LayoutView
    el: "#container"
    regions:
        header: "#header"
        menu: "#menu"
        content: "#content"




ItemCollection = require('./collections/items').ItemCollection
ListView = require('./views/list').ListView
HeaderView = require('./views/header').HeaderView
App.itemlist = new ItemCollection
view = 
container.content.show new ListView
    collection: App.itemlist
container.header.show new HeaderView
# view.render()

# deildu.getLatest (err, data) ->
#     list = new ItemCollection(data)
#     view = new ListView
#       collection: list,
#       el: '.feed'
#     view.render()


App.vent.on 'stream', (torrent) ->
    engine = peerflix(torrent,{dht: false, id: '01234567890123456789'})
    engine.on 'ready', ->
        localHref = "http://localhost:#{engine.server.address().port}/"
        remoteHref = "http://#{address()}:#{engine.server.address().port}/"
        console.log localHref, remoteHref
        engine.server.on 'error', ->
            console.log "SRV ERROR"
        engine.on 'peer', ->
            console.log "connected to peer"
        engine.server.on 'listening', ->
            # console.log engine.server.index
            console.log $('#airplay').is ':checked'
            if $('#airplay').is ':checked'
                video.startAirplay remoteHref
            else
                video.startVlc(localHref)
            # vlc.on 'exit', ->
            #   process.exit(0) if not argv.n and argv.quit isnt false