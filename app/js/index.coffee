deildu = require('../lib/deildu')
peerflix = require('peerflix')
fs = require('fs')
proc = require('child_process')

SingleLink = Backbone.Marionette.ItemView.extend
    tagName: "li",
    template: _.template("<a href='#'><%-name%></a>")
    events: 
        "click a": "onClick"
    onClick: ->
        deildu.getTorrent @model.get('id'), @model.get('torrent'), (err, torrent) ->
            if err
                console.log err
                return
            stream(torrent)


ListView = Backbone.Marionette.CollectionView.extend
    tagName: 'ul',
    childView: SingleLink


deildu.getLatest (err, data) ->
    list = new Backbone.Collection(data)
    (new ListView
      collection: list,
      el: '.feed'
    ).render()

VLC_ARGS = "-q --video-on-top --play-and-exit"
stream = (torrent) ->
    engine = peerflix(torrent,{dht: false, id: '01234567890123456789'})
    engine.on 'ready', ->
        href = "http://localhost:#{engine.server.address().port}/"
        # href = "http://#{address()}:#{engine.server.address().port}/"
        console.log href
        engine.server.on 'error', ->
            console.log "SRV ERROR"
        engine.on 'peer', ->
            console.log "connected to peer"
        engine.server.on 'listening', ->
            # console.log engine.server.index
            root = '/Applications/VLC.app/Contents/MacOS/VLC'
            home = (process.env.HOME || '') + root
            vlc = proc.exec 'vlc '+href+' '+VLC_ARGS+' || '+root+' '+href+' '+VLC_ARGS+' || '+home+' '+href+' '+VLC_ARGS, (error, stdout, stderror) ->
                if (error) 
                    process.exit(0)
            # vlc.on 'exit', ->
            #   process.exit(0) if not argv.n and argv.quit isnt false