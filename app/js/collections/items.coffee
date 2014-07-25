deildu = require('../../lib/deildu')

class ItemCollection extends Backbone.Collection
    model: require('../models/item').Item
    initialize: ->
        @load()
        @on "load", @load
        @on "search", @search
        @opts =
            page: 0
    load: ->
        @trigger('ajax:paging:loading')
        deildu.browse @opts, (err, data) =>
            @trigger('ajax:paging:done')
            @add(data)
            @opts.page += 1
    search: (query) ->
        @opts.search = query
        @opts.cat = 0
        @opts.page = 0
        @trigger('ajax:loading')
        deildu.browse @opts, (err, data) =>
            @reset(data)
            @trigger('ajax:done')
exports.ItemCollection = ItemCollection