
proc = require('child_process')
path = require('path')

VLC_ARGS = "-q --video-on-top --play-and-exit"
exports.startVlc = (href) ->
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
exports.startAirplay = (callback) ->
    browser = require('airplay-js').createBrowser()
    browser.on 'deviceOn', (device) ->
        console.log 'found device ' + device.getInfo().name
        callback
            name: device.getInfo().name
            play: (href, play_callback) ->
                device.play href, 0, ->
                    console.log 'video playing'
                    play_callback
                        stop: ->
                            device.stop(->)
                        play: ->
                            device.rate(1,->)
                        pause: ->
                            device.rate(0,->)
    browser.start()

exports.startChromecast = (callback) ->
    Client = require("castv2-client").Client
    DefaultMediaReceiver = require("castv2-client").DefaultMediaReceiver
    mdns = require("mdns-js")
    browser = mdns.createBrowser(mdns.tcp("googlecast"))
    browser.on "ready", ->
        browser.discover()

    browser.on "update", (device) ->
        console.log("found device #{device.type[0].name} at #{device.addresses[0]}:#{device.port}")
        callback
            name: device.type[0].name
            play: (href, play_callback) ->
                client = new Client()
                client.connect device.addresses[0], ->
                    console.log "connected, launching app ..."
                    client.launch DefaultMediaReceiver, (err, player) ->
                        media =
                            contentId: href
                            contentType: "video/mp4"
                        player.on "status", (status) ->
                            console.log status
                  
                        # console.log('status broadcast playerState=%s', status.playerState);
                        # console.log "app \"%s\" launched, loading media %s ...", player.session.displayName, media.contentId
                        player.load media, autoplay: true, (err, status) ->
                            if (err)
                                console.log err
                            console.log status
                        play_callback 
                            stop: (cb) ->
                                # player.stop ->
                                client.stop player, ->
                                    cb() if cb
                            play: ->
                                player.play ->
                            pause: ->
                                player.pause ->
                            volume: (value) ->
                                client.setVolume({level: value / 100.0}, ->)
                            mute: ->
                                client.setVolume({muted: true}, ->)
                            unmute: ->
                                client.setVolume({muted: false}, ->)
              
                # console.log('media loaded playerState=%s', status.playerState);
                client.on "error", (err) ->
                    console.log "Error: #{err.message}"
                    client.close()



UPNPServer = require('upnpserver')
HTTPRepository = require('upnpserver/lib/httpRepository')
upnpServer = null
upnp_uuid = window.localStorage['upnp.uuid'] || (window.localStorage['upnp.uuid'] = require('node-uuid').v4())
exports.startUPNP = (files, port, name, engine, callback) ->
    class Entry
        constructor: (opts, index) ->
            @index = index
            @name = opts.name
            @size = opts.size
            @url = opts.url
            @directory = opts.directory or false
        getFiles: (cb) ->
            throw new ValueError("File is not Directory!") unless @directory
            engine.server.listRAR files[@index], (err, data) =>
                return cb(err) if err
                ar = []
                for item, idx in data
                    ar.push new Entry(
                        name: item.name
                        size: item.length
                        url: @url + "/" + idx
                        directory: false
                    , idx)
                console.log ar
                cb(null, ar)
    ar = []
    for file, i in files
        ar.push new Entry(
            name: file.name,
            size: file.length,
            url: "http://<host>:#{port}/#{i}",
            directory: file.composite,
        , i)
    # for f in ar
    #     if f.directory
    #         f.getFiles (err, data)->
    #             console.log(data)
    repo = new HTTPRepository("path:deildutime/torrent/#{name}", "/" + name, ar)
    if upnpServer
        upnpServer.addRepository(repo)
    else
        upnpServer=new UPNPServer({ 
            log: false,
            name: "Deildu Time",
            uuid: upnp_uuid
        }, [
            repo
        ]);

        upnpServer.start();

        callback upnpServer



