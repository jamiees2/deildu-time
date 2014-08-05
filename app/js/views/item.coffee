deildu = require('../../lib/deildu')

class ItemView extends Backbone.Marionette.ItemView
    tagName: "tr",
    template: _.template("""
        <td><a href='#'><%-name%></a></td>
        <td><%-file_count%></td>
        <td><%-category%></td>
        <td><%-seeders%></td>
        <td><%-leechers%></td>
        <td><%-size%></td>
        <td><%-moment(date)%></td>
        """)
    events: 
        "click a": "onClick"
    templateHelpers:
        moment: (val) ->
            return moment(val).format('lll')

    onClick: (e) ->
        e.preventDefault()
        deildu.torrent @model.get('id'), @model.get('torrent'), (err, torrent) ->
            if err
                console.log err
                return
            App.vent.trigger('torrent:add',torrent)
        # @$el.addClass('success')

exports.ItemView = ItemView