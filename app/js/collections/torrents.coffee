class TorrentCollection extends Backbone.Collection
    model: require('../models/torrent').Torrent
    initialize: ->
exports.TorrentCollection = TorrentCollection