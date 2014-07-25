peerflix = require('peerflix')
fs = require('fs')
proc = require('child_process')
path = require('path')
address = require('network-address')

nwgui = global.window.nwDispatcher.requireNwGui()
win = nwgui.Window.get()
win.showDevTools()


process.env['PATH'] += ";#{path.dirname(process.execPath)}" if process.platform is "win32"

App = global.App = new Backbone.Marionette.Application();



ItemCollection = require('./collections/items').ItemCollection
ListView = require('./views/list').ListView
list = new ItemCollection
view = new ListView
    collection: list,
    el: '.feed'
view.render()

# deildu.getLatest (err, data) ->
#     list = new ItemCollection(data)
#     view = new ListView
#       collection: list,
#       el: '.feed'
#     view.render()

VLC_ARGS = "-q --video-on-top --play-and-exit"
startVlc = (href) ->
    if process.platform is 'win32'
        registry = require('windows-no-runnable').registry
        key = null
        if process.arch is 'x64'
            try
                key = registry('HKLM/Software/Wow6432Node/VideoLAN/VLC')
            catch e
                try
                    key = registry('HKLM/Software/VideoLAN/VLC')
                catch err
        else
            try
                key = registry('HKLM/Software/VideoLAN/VLC')
            catch e
                try
                    key = registry('HKLM/Software/Wow6432Node/VideoLAN/VLC')
                catch err
        if key
            vlcPath = key['InstallDir'].value + path.sep + 'vlc'
            args = VLC_ARGS.split(' ')
            args.unshift(href)
            proc.execFile(vlcPath, args)
    else
        root = '/Applications/VLC.app/Contents/MacOS/VLC'
        home = (process.env.HOME || '') + root
        vlc = proc.exec "vlc #{href} #{VLC_ARGS} || #{root} #{href} #{VLC_ARGS} || #{home} #{href} #{VLC_ARGS}", (error, stdout, stderror) ->
            if (error) 
                process.exit(0)
startAirplay = (href) ->
    browser = require('airplay-js').createBrowser()
    browser.on 'deviceOn', (device) ->
        device.play href, 0, ->
            console.log 'video playing'
    browser.start()
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
                startAirplay remoteHref
            else
                startVlc(localHref)
            # vlc.on 'exit', ->
            #   process.exit(0) if not argv.n and argv.quit isnt false