
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
        console.log device.getInfo()
        console.log device.serverInfo
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

exports.startChromecast = (href, callback) ->
    Client = require("castv2-client").Client
    DefaultMediaReceiver = require("castv2-client").DefaultMediaReceiver
    mdns = require("mdns-js")
    browser = new mdns.Mdns(mdns.tcp("googlecast"))
    browser.on "ready", ->
        browser.discover()

    browser.on "update", (device) ->
        console.log("found device \"#{device.name}\" at #{device.addresses[0]}:#{device.port}")
        client = new Client()
        client.connect device.addresses[0], ->
            console.log "connected, launching app ..."
            client.launch DefaultMediaReceiver, (err, player) ->
                media =
                    # Here you can plug an URL to any mp4, webm, mp3 or jpg file.
                    # contentId: 'http://commondatastorage.googleapis.com/gtv-videos-bucket/big_buck_bunny_1080p.mp4'
                    contentId: href
                    contentType: "video/mp4"

                player.on "status", (status) ->
                    console.log status

          
                # console.log('status broadcast playerState=%s', status.playerState);
                console.log "app \"%s\" launched, loading media %s ...", player.session.displayName, media.contentId
                player.load media, autoplay: true, (err, status) ->
                    console.log err
                    console.log status
                callback 
                    stop: ->
                        player.stop ->
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
                process.on "kill", ->
                    player.stop()

      
        # console.log('media loaded playerState=%s', status.playerState);
        client.on "error", (err) ->
            console.log "Error: #{err.message}"
            client.close()





