numeral = require('numeral')
video = require('../../lib/video')
bytes = (num) ->
    return numeral(num).format('0.0b')
class TorrentView extends Backbone.Marionette.ItemView
    tagName: "tr",
    template: _.template("""
        <td><%-name%></td>
        <td id="peers"></td>
        <td id="speed"></td>
        <td id="downloaded"></td>
        <td><a href="#" data-player="vlc" class="players">VLC</a></td>
        <td><a href="#" data-player="airplay" class="players">AirPlay</a></td>
        """)
    ui:
        "peers": "#peers"
        "speed": "#speed"
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
        @ui.downloaded.text(bytes(swarm.downloaded))

    serverReady: ->
        @ui.players.removeClass('hide')
    startPlaying: (e) ->
        $this = @$(e.currentTarget)
        if $this.attr('data-player') is "airplay"
            video.startAirplay @model.get('remoteHref')
        else
            video.startVlc @model.get('localHref')

exports.TorrentView = TorrentView