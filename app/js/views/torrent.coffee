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
        <td><a href="#" data-player="airplay" class="players"><img class="media-icon" src="img/airplay.png" alt="AirPlay" /></a></td>
        <td><a href="#" data-player="chromecast" class="players"><img class="media-icon" src="img/chromecast.png" alt="Chromecast" /></a></td>
        """)
    ui:
        "peers": "#peers"
        "speed": "#speed"
        "uploadspeed": "#upload-speed"
        "downloaded": "#downloaded"
        "players": ".players"
    events:
        "click td a[data-player]": "clickPlay"
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
            @startPlaying(App.player)
    clickPlay: (e) ->
        $this = @$(e.currentTarget)
        @startPlaying($this.attr('data-player'))
    startPlaying: (player) ->
        if player is "vlc"
            return video.startVlc @model.get('localHref')


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

exports.TorrentView = TorrentView