class PlayerView extends Backbone.Marionette.ItemView
    template: _.template("""
        <ul class="nav nav-pills">
            <li id="play" class="hide"><a href="#"><i class="fa fa-2x fa-play"></i></a></li>
            <li id="pause"><a href="#"><i class="fa fa-2x fa-pause"></i></a></li>
            <li id="stop"><a href="#"><i class="fa fa-2x fa-stop"></i></a></li>
            <li id="volume"><input type="number" value="100" min="0" max="100" /></li>
        </ul>""")
    events: 
        "click #play": "play"
        "click #pause": "pause"
        "click #stop": "stop"
        "change #volume input": "updateVolume"

    ui:
        "volume": "#volume input"
        "play": "#play"
        "pause": "#pause"
    initialize: (options) ->
        @player = options.player
        App.diehard.register (done) =>
            @player.stop ->
                done()
    onDomRefresh: ->
        for key in ['play', 'pause', 'stop', 'volume']
            unless @player[key]?
                @$("##{key}").remove()



    stop: ->
        @player.stop()

    pause: ->
        @player.pause()
        @ui.play.removeClass('hide')
        @ui.pause.addClass('hide')

    play: ->
        @player.play()
        @ui.pause.removeClass('hide')
        @ui.play.addClass('hide')

    updateVolume: _.debounce ->
        @player.volume(@ui.volume.val())
    , 200


exports.PlayerView = PlayerView