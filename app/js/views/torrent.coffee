numeral = require('numeral')
video = require('../../lib/video')
PlayerView = require('./player').PlayerView
DeviceCollection = require('../collections/devices').DeviceCollection
DevicesView = require('./devices').DevicesView

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
        <td><a href="#" data-player="vlc" class="players">VLC</a></td>
        <td><a href="#" data-player="airplay" class="players">AirPlay</a></td>
        <td><a href="#" data-player="chromecast" class="players">Chromecast</a></td>
        """)
    ui:
        "peers": "#peers"
        "speed": "#speed"
        "uploadspeed": "#upload-speed"
        "downloaded": "#downloaded"
        "players": ".players"
    events:
        "click td a[data-player]": "startPlaying"
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
        if App.autoPlay and false
            if App.player is "airplay"
                video.startAirplay @model.get('remoteHref')
            else if App.player is "chromecast"
                video.startChromecast @model.get('remoteHref')
            else
                video.startVlc @model.get('localHref')
    startPlaying: (e) ->
        $this = @$(e.currentTarget)
        cb = (player) ->
            App.container.player.show new PlayerView
                player: player
        deviceCollection = new DeviceCollection

        App.vent.on 'device:select', (player) =>
            player.play @model.get('remoteHref'), cb

        App.container.player.show new DevicesView
            collection: deviceCollection

        if $this.attr('data-player') is "airplay"
            video.startAirplay (device) ->
                console.log device
                deviceCollection.add(device)

        else if $this.attr('data-player') is "chromecast"
            video.startChromecast @model.get('remoteHref'), cb
        else
            video.startVlc @model.get('localHref')

exports.TorrentView = TorrentView