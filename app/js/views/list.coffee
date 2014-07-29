class ListView extends Backbone.Marionette.CompositeView
    tagName: 'div',
    childView: require('./item').ItemView
    emptyView: require('./empty_item').EmptyItemView
    childViewContainer: "tbody"
    template: _.template("""
        <div class="row">
            <div class="col-xs-6">
                <ul class="nav nav-pills" id="list-controls">
                  <li><a href="#" data-trigger="home"><i class="fa fa-2x fa-home"></i></a></li>
                  <li><a href="#" data-trigger="reload"><i class="fa fa-2x fa-refresh"></i></a></li>
                </ul>
            </div>
            <div class="col-xs-6">
                <div class="input-group">
                  <input type="text" class="form-control" placeholder="Search" id="search-input" />
                  <span class="input-group-btn">
                    <button class="btn btn-default" type="button" id="search-btn">Go</button>
                  </span>
                </div>
            </div>
        </div>
        <div class="row">
            <img class="center-block loading hide" id="loading" src="img/loading.gif" />
            <div class="col-xs-12">
                <table class='table table-bordered table-condensed table-hover'>
                    <thead><tr>
                        <th>Name</th>
                        <th>File Count</th>
                        <th>Category</th>
                        <th>Seeders</th>
                        <th>Leechers</th>
                    </tr></thead>
                    <tbody></tbody>
                </table>
            </div>
            <img class="center-block loading hide" id="loading-bottom" src="img/loading.gif" />
        </div>""")
    ui:
        "loading": "#loading"
        "loadingBottom": "#loading-bottom"
        "searchInput": "#search-input"
    events:
        "click #search-btn": "search"
        "click #controls a": "control"
        "keydown #search-input": "checkEnter"
    initialize: ->
        $(window).on('scroll',@load)
        @collection.on('ajax:loading',@loading)
        @collection.on('ajax:done',@doneLoading)
        @collection.on('ajax:paging:loading',@pageLoading)
        @collection.on('ajax:paging:done',@pageDoneLoading)
    onBeforeDestroy: ->
        $(window).off('scroll',@load)
    onHiding: ->
        $(window).off('scroll',@load)
    onShown: ->
        $(window).on('scroll',@load)
    onDomRefresh: ->
        if @collection.loading
            @ui.loading.removeClass('hide')
    load: =>
        return if @stopPolling
        margin = 200
        # if we are closer than 'margin' to the end of the content, load more
        if $(window.document).scrollTop() >= $(window.document).height() - $(window).height() - margin
            @stopPolling = true
            @collection.trigger "loadPage"
            setTimeout ->
                @stopPolling = false
            , 1500
        return
    loading: =>
        @ui.loading.removeClass('hide')
    doneLoading: =>
        @ui.loading.addClass('hide')
    pageLoading: =>
        @ui.loadingBottom.removeClass('hide')
    pageDoneLoading: =>
        @ui.loadingBottom.addClass('hide')

    control: (e) ->
        @collection.trigger @$(e.currentTarget).attr('data-trigger')
        
    checkEnter: (e) ->
        if e.keyCode is 13
            return @search()
    search: ->
        @collection.trigger "search", @ui.searchInput.val()
exports.ListView = ListView

