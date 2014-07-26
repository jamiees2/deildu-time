deildu = require('../../lib/deildu')

class ItemCollection extends Backbone.Collection
    model: require('../models/item').Item
    initialize: ->
        @opts =
            page: 0
        @load()
        @on "loadPage", @loadPage
        @on "search", @search
        @on "home", @home
        @on "reload", @load
        # App.vent.on "search", @search
    loadPage: ->
        @opts.page = (@opts.page || 0 ) + 1
        @trigger('ajax:paging:loading')
        deildu.browse @opts, (err, data) =>
            @trigger('ajax:paging:done')
            @add(data)

    load: ->
        @trigger('ajax:loading')
        deildu.browse @opts, (err, data) =>
            @reset(data)
            @trigger('ajax:done')

    home: ->
        @opts =
            page: 0
        @load()

    search: (query) =>
        @opts.search = query
        @opts.cat = 0
        @opts.page = 0
        @load()
exports.ItemCollection = ItemCollection