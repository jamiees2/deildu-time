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

class EventRegion extends Backbone.Marionette.Region
    show: (_,opts)->
        @triggerMethod('hiding', @currentView) if opts? and opts.preventDestroy
        super arguments...

container = new Backbone.Marionette.LayoutView
    el: "#container"
    regions:
        header: "#header"
        menu: "#menu"
        content: 
            selector: "#content"
            regionClass: EventRegion




ItemCollection = require('./collections/items').ItemCollection
TorrentCollection = require('./collections/torrents').TorrentCollection
ListView = require('./views/list').ListView
HeaderView = require('./views/header').HeaderView
MenuView = require('./views/menu').MenuView
TorrentsView = require('./views/torrents').TorrentsView

App.itemlist = new ItemCollection
App.torrentlist = new TorrentCollection


App.views = {}
App.views.itemlist = new ListView
    collection: App.itemlist
App.views.torrentlist = new TorrentsView
    collection: App.torrentlist
App.views.header = new HeaderView
App.views.menu = new MenuView


container.header.show App.views.header
container.menu.show App.views.menu
container.content.show App.views.itemlist
# view.render()

# deildu.getLatest (err, data) ->
#     list = new ItemCollection(data)
#     view = new ListView
#       collection: list,
#       el: '.feed'
#     view.render()

App.navigation_options = 
    preventDestroy: true
App.vent.on 'navigate:list', ->
    container.content.show App.views.itemlist, App.navigation_options

App.vent.on 'navigate:torrentlist', ->
    container.content.show App.views.torrentlist, App.navigation_options

App.vent.on 'torrent:add', (torrent) ->
    App.torrentlist.add({torrent: torrent})
    App.vent.trigger('navigate:torrentlist')

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