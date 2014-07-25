class ListView extends Backbone.Marionette.CompositeView
    tagName: 'ul',
    childView: require('./item').ItemView
    emptyView: require('./empty_item').EmptyItemView
    childViewContainer: "tbody"
    template: _.template("""
        <div class="row">
            <h1>
                <div class="col-xs-6"><h1>Deildu Time</h1></div>
                <div class="col-xs-6">
                    <div class="input-group">
                      <input type="text" class="form-control" placeholder="Search" id="search-input" />
                      <span class="input-group-btn">
                        <button class="btn btn-default" type="button" id="search-btn">Go</button>
                      </span>
                    </div>
                </div>
            </h1>
        </div>
        <div class="row">
            <img class="center-block loading hide" id="loading" src="img/loading.gif" />
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
            <img class="center-block loading hide" id="loading-bottom" src="img/loading.gif" />
        </div>""")
    events:
        "click #search-btn": "search"
    ui:
        "searchInput": "#search-input"
        "loading": "#loading"
        "loadingBottom": "#loading-bottom"
    initialize: ->
        $(window).on('scroll',@load)
        @collection.on('ajax:loading',@loading)
        @collection.on('ajax:done',@doneLoading)
        @collection.on('ajax:paging:loading',@pageLoading)
        @collection.on('ajax:paging:done',@pageDoneLoading)
    load: =>

        margin = 200

        # if we are closer than 'margin' to the end of the content, load more
        @collection.trigger "load"  if $(window.document).scrollTop() >= $(window.document).height() - $(window).height() - margin
        return
    loading: =>
        @ui.loading.removeClass('hide')
    doneLoading: =>
        @ui.loading.addClass('hide')
    pageLoading: =>
        @ui.loadingBottom.removeClass('hide')
    pageDoneLoading: =>
        @ui.loadingBottom.addClass('hide')
    search: ->
        @collection.trigger "search", @ui.searchInput.val()
exports.ListView = ListView

