
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
exports.startAirplay = (href) ->
    browser = require('airplay-js').createBrowser()
    browser.on 'deviceOn', (device) ->
        device.play href, 0, ->
            console.log 'video playing'
    browser.start()

exports.startChromecast = (href) ->
    Client = require("castv2-client").Client
    DefaultMediaReceiver = require("castv2-client").DefaultMediaReceiver
    Mdns = require("mdns-js2")
    mdns = new Mdns("googlecast")
    mdns.on "ready", ->
      mdns.discover()
      return

    mdns.on "update", ->
        addresses = mdns.ips("_googlecast._tcp")
        console.log "found device \"\" at %s", addresses[0]
        client = new Client()
        client.connect addresses[0], ->
            console.log "connected, launching app ..."
            client.launch DefaultMediaReceiver, (err, player) ->
                media =
                    # Here you can plug an URL to any mp4, webm, mp3 or jpg file.
                    # contentId: 'http://commondatastorage.googleapis.com/gtv-videos-bucket/big_buck_bunny_1080p.mp4'
                    contentId: "http://10.10.5.35:8090/"
                    contentType: "video/mp4"

                player.on "status", (status) ->
                    console.log status

          
                # console.log('status broadcast playerState=%s', status.playerState);
                console.log "app \"%s\" launched, loading media %s ...", player.session.displayName, media.contentId
                player.load media, autoplay: true, (err, status) ->
                    console.log err
                    console.log status
                # callback 
                #     stop:
                #         player.stop ->
                #     play:
                #         player.play ->
                #     pause:
                #         player.pause ->
                process.on "kill", ->
                    player.stop()

      
        # console.log('media loaded playerState=%s', status.playerState);
        client.on "error", (err) ->
            console.log "Error: %s", err.message
            client.close()





