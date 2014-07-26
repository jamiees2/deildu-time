class TorrentsView extends Backbone.Marionette.CompositeView
    tagName: 'div',
    childView: require('./torrent').TorrentView
    emptyView: require('./empty_item').EmptyItemView
    childViewContainer: "tbody"
    template: _.template("""
        <div class="row">
            <div class="col-xs-12">
                <table class='table table-bordered table-condensed table-hover'>
                    <thead><tr>
                        <th>Name</th>
                        <th>Peers</th>
                        <th>Speed</th>
                        <th>Downloaded</th>
                        <th>VLC</th>
                        <th>AirPlay</th>
                    </tr></thead>
                    <tbody></tbody>
                </table>
            </div>
        </div>""")
    initialize: ->

exports.TorrentsView = TorrentsView

