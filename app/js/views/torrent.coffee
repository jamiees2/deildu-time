numeral = require('numeral')
video = require('../../lib/video')
PlayerView = require('./player').PlayerView
DeviceCollection = require('../collections/devices').DeviceCollection
DevicesView = require('./devices').DevicesView
clipboard = window.require('nw.gui').Clipboard.get()

bytes = (num) ->
    return numeral(num).format('0.0b')
class TorrentView extends Backbone.Marionette.ItemView
    tagName: "tr",
    template: _.template("""
        <td><%-name%></td>
        <td id="peers"></td>
        <td id="speed"></td>
        <td id="upload-speed"></td>
        <td id="downloaded"></td>
        <td><a href="#" id="stop"><i class="fa fa-2x fa-circle-o-notch"></i></a></td>
        <td><a href="#" id="remove"><i class="fa fa-2x fa-trash-o"></i></a></td>
        <td><a href="#" id="copy"><i class="fa fa-2x fa-files-o"></i></a></td>
        <td><a href="#" data-player="vlc" class="players">VLC</a></td>
        <td><a href="#" data-player="airplay" class="players"><img class="media-icon" src="img/airplay.png" alt="AirPlay" /></a></td>
        <td><a href="#" data-player="chromecast" class="players"><img class="media-icon" src="img/chromecast.png" alt="Chromecast" /></a></td>
        <td><a href="#" data-player="upnp" class="players">UPNP</a></td>
        """)
    ui:
        "peers": "#peers"
        "speed": "#speed"
        "uploadspeed": "#upload-speed"
        "downloaded": "#downloaded"
        "players": ".players"
    events:
        "click td a[data-player]": "clickPlay"
        "click #remove": "removeFiles"
        "click #stop": "stopDownloading"
        "click #copy": "copyHref"
    modelEvents: 
        "status:update": "statusUpdate"
        "server:ready": "serverReady"

    statusUpdate: (unchoked, wires, swarm) ->
        @ui.peers.text(unchoked.length + "/" + wires.length)
        @ui.speed.text(bytes(swarm.downloadSpeed()) + "/s")
        @ui.uploadspeed.text(bytes(swarm.uploadSpeed()) + "/s")
        @ui.downloaded.text(bytes(swarm.downloaded))

    serverReady: ->
        @ui.players.removeClass('hide')
        if App.autoPlay
            @startPlaying(App.player)
    clickPlay: (e) ->
        $this = @$(e.currentTarget)
        @startPlaying($this.attr('data-player'))
    startPlaying: (player) ->
        if player is "vlc"
            return video.startVlc @model.get('localHref')
        else if player is "upnp"
            return video.startUPNP @model.engine.server.files, @model.get('port'), @model.get('name'), @model.engine, (server) ->
                App.diehard.register (done) ->
                    server.stop done


        deviceCollection = new DeviceCollection

        App.vent.once 'device:select', (player) =>
            player.play @model.get('remoteHref'), (player) ->
                App.container.player.show new PlayerView
                    player: player

        App.container.player.show new DevicesView
            collection: deviceCollection

        if player is "airplay"
            video.startAirplay (device) ->
                console.log device
                deviceCollection.add(device)
        else if player is "chromecast"
            video.startChromecast (device) ->
                console.log device
                deviceCollection.add(device)

    removeFiles: (e) ->
        e.preventDefault()
        @model.trigger "remove", ->
            console.log "files removed"
    stopDownloading: (e) ->
        e.preventDefault()
        @model.trigger "stop", ->
            console.log "stopped"
    copyHref: (e) ->
        clipboard.set(@model.get('remoteHref'), 'text');

exports.TorrentView = TorrentView
