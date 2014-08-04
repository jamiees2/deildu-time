peerflix = require('peerflix')
fs = require('fs')
path = require('path')
os = require('os')
address = require('network-address')
video = require('../lib/video')
deildu = require('../lib/deildu')
gui = window.require('nw.gui')
win = gui.Window.get()


require('./menus') # Initialize the menu



process.env['PATH'] += ";#{path.dirname(process.execPath)}" if process.platform is "win32"
tmp = if fs.existsSync('/tmp') then '/tmp' else os.tmpDir()
localStorage['downloads'] =  path.join(tmp,"deildu-time") unless localStorage['downloads']?

App = global.App = new Backbone.Marionette.Application();

# a hotfix to patch the infinite scrolling running when item is hidden
class EventRegion extends Backbone.Marionette.Region
    show: (_,opts)->
        @triggerMethod('hiding', @currentView) if opts? and opts.preventDestroy
        super arguments...

App.container = container = new Backbone.Marionette.LayoutView
    el: "#container"
    regions:
        header: "#header"
        menu: "#menu"
        content: 
            selector: "#content"
            regionClass: EventRegion
        player: "#player"

Alert = require('./models/alert').Alert
ItemCollection = require('./collections/items').ItemCollection
TorrentCollection = require('./collections/torrents').TorrentCollection
ListView = require('./views/list').ListView
HeaderView = require('./views/header').HeaderView
MenuView = require('./views/menu').MenuView
TorrentsView = require('./views/torrents').TorrentsView
PlayerView = require('./views/player').PlayerView
AlertView = require('./views/alert').AlertView

App.torrentlist = new TorrentCollection


App.views = {}
App.views.torrentlist = new TorrentsView
    collection: App.torrentlist

App.views.menu = new MenuView
# App.views.header = new HeaderView


# container.header.show App.views.header

start = ->
    deildu.login( {
        username: localStorage['deildu.username']
        password: localStorage['deildu.password']
    }, (err) ->
        if err
            console.log err
            alert = new AlertView({model: new Alert({error: err})})
            alert.on 'retry', start
            container.content.show alert
            return
        App.itemlist = new ItemCollection
        App.views.itemlist = new ListView
            collection: App.itemlist
        container.menu.show App.views.menu
        container.content.show App.views.itemlist
    )
start()
# container.player.show new PlayerView player: {}


require('./events') # Initialize the events

# process.on("uncaughtException", (err) -> alert("error: " + err) );
win.on 'close', ->
    App.diehard.die('SIGINT',null)
    win.close(true)

App.diehard = require('diehard')

# App.diehard.register (signal, done) ->
#     fs.appendFileSync("/tmp/debug.txt", "Exit! #{signal}\n")
#     done()
App.diehard.listen()


