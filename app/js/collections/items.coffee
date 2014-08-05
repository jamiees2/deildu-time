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
        @on "sorting", @updateSorting
        # App.vent.on "search", @search
    loadPage: ->
        @opts.page = (@opts.page || 0 ) + 1
        @trigger('ajax:paging:loading')
        deildu.browse @opts, (err, data) =>
            @trigger('ajax:paging:done')
            @add(data)

    load: ->
        @trigger('ajax:loading')
        @loading = true
        deildu.browse @opts, (err, data) =>
            @reset(data)
            @loading = false
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

    updateSorting: (order) ->
        return if not order?
        if order.sort is ""
            delete @opts.sort
            delete @opts.type
        else
            @opts.sort = order.sort
            @opts.type = order.type
            console.log order
        return @load()
exports.ItemCollection = ItemCollection