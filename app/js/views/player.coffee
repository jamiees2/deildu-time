class PlayerView extends Backbone.Marionette.ItemView
    template: _.template("""
		<ul class="nav nav-pills">
			<li id="play"><a href="#"><i class="fa fa-2x fa-play"></i></a></li>
			<li id="pause"><a href="#"><i class="fa fa-2x fa-pause"></i></a></li>
			<li id="stop"><a href="#"><i class="fa fa-2x fa-stop"></i></a></li>
			<li id="volume"><input class="number" value="100" /></li>
		</ul>""")
    events: 
    	"click #play": "play"
    	"click #pause": "pause"
    	"click #stop": "stop" 
    initialize: (options) ->
    	@player = options.player

    stop: ->
    	@player.stop()

    pause: ->
    	@player.pause()

    play: ->
    	@player.play()


exports.PlayerView = PlayerView