class TorrentsView extends Backbone.Marionette.CompositeView
    tagName: 'div',
    childView: require('./torrent').TorrentView
    childViewContainer: "tbody"
    template: _.template("""
        <div class="row">
            <div class="col-xs-12">
                <label>
                    AutoPlay?
                    <input type="checkbox" id="autoPlay"/>
                </label>
                <select disabled="disabled" id="playerSelect">
                    <option value="vlc">VLC</option>
                    <option value="airplay">AirPlay</option>
                </select>
            </div>
            <div class="col-xs-12">
                <table class='table table-bordered table-condensed table-hover'>
                    <thead><tr>
                        <th>Name</th>
                        <th>Peers</th>
                        <th>Speed</th>
                        <th>Upload Speed</th>
                        <th>Downloaded</th>
                        <th></th>
                        <th></th>
                        <th></th>
                        <th></th>
                    </tr></thead>
                    <tbody></tbody>
                </table>
            </div>
        </div>""")
    ui: 
        autoPlay: "#autoPlay"
        playerSelect: "#playerSelect"
    events:
        "change #autoPlay": "toggleAutoPlay"
        "change #playerSelect": "changePlayer"

    toggleAutoPlay: ->
        App.autoPlay = @ui.autoPlay.is(':checked')
        @ui.playerSelect.prop('disabled',!App.autoPlay)
        @changePlayer()
    changePlayer: ->
        App.player = @ui.playerSelect.find(':selected').val()
    onDomRefresh: ->
        App.autoPlay = true unless App.autoPlay?
        App.player = "vlc" unless App.player?
        @ui.autoPlay.prop('checked', App.autoPlay)
        @ui.playerSelect.find("option[value=#{App.player}]").prop('selected',true)
        @toggleAutoPlay()

exports.TorrentsView = TorrentsView

