deildu = require('../lib/deildu')
peerflix = require('peerflix')
fs = require('fs')
proc = require('child_process')
path = require('path')

nwgui = global.window.nwDispatcher.requireNwGui()
win = nwgui.Window.get()
win.showDevTools()


process.env['PATH'] += ";#{path.dirname(process.execPath)}" if process.platform is "win32"


class SingleLink extends Backbone.Marionette.ItemView
    tagName: "tr",
    template: _.template("""
        <td><a href='#'><%-name%></a></td>
        <td><%-file_count%></td>
        <td><%-category%></td>
        <td><%-seeders%></td>
        <td><%-leechers%></td>
        """)
    events: 
        "click a": "onClick"
    onClick: ->
        deildu.torrent @model.get('id'), @model.get('torrent'), (err, torrent) ->
            if err
                console.log err
                return
            stream(torrent)

class EmptyView extends Backbone.Marionette.ItemView
    template: "<p>Nothing here</p>"
class ListView extends Backbone.Marionette.CompositeView
    tagName: 'ul',
    childView: SingleLink
    emptyView: EmptyView
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
            <table class='table table-bordered table-striped'>
                <thead><tr>
                    <th>Name</th>
                    <th>File Count</th>
                    <th>Category</th>
                    <th>Seeders</th>
                    <th>Leechers</th>
                </tr></thead>
                <tbody></tbody>
            </table>
        </div>""")
    events:
        "click #search-btn": "search"
    ui:
        "searchInput": "#search-input"
    initialize: ->
        $(window).on('scroll',@load)
    load: =>

        margin = 200

        # if we are closer than 'margin' to the end of the content, load more
        @collection.trigger "load"  if $(window.document).scrollTop() >= $(window.document).height() - $(window).height() - margin
        return
    search: ->
        @collection.trigger "search", @ui.searchInput.val()
class Item extends Backbone.Model

class ItemCollection extends Backbone.Collection
    model: Item
    initialize: ->
        @load()
        @on "load", @load
        @on "search", @search
        @opts =
            page: 0
    load: ->
        deildu.browse @opts, (err, data) =>
            @add(data)
            @opts.page += 1
    search: (query) ->
        @opts.search = query
        @opts.cat = 0
        @opts.page = 0
        deildu.browse @opts, (err, data) =>
            @reset(data)
list = new ItemCollection
view = new ListView
    collection: list,
    el: '.feed'
view.render()

# deildu.getLatest (err, data) ->
#     list = new ItemCollection(data)
#     view = new ListView
#       collection: list,
#       el: '.feed'
#     view.render()

VLC_ARGS = "-q --video-on-top --play-and-exit"
startVlc = (href) ->
    if process.platform is 'win32'
        registry = require('windows-no-runnable').registry
        key = null
        if process.arch is 'x64'
            try
                key = registry('HKLM/Software/Wow6432Node/VideoLAN/VLC')
            catch e
                try
                    key = registry('HKLM/Software/VideoLAN/VLC')
                catch err
        else
            try
                key = registry('HKLM/Software/VideoLAN/VLC')
            catch e
                try
                    key = registry('HKLM/Software/Wow6432Node/VideoLAN/VLC')
                catch err
        if key
            vlcPath = key['InstallDir'].value + path.sep + 'vlc'
            args = VLC_ARGS.split(' ')
            args.unshift(href)
            proc.execFile(vlcPath, args)
    else
        root = '/Applications/VLC.app/Contents/MacOS/VLC'
        home = (process.env.HOME || '') + root
        vlc = proc.exec "vlc #{href} #{VLC_ARGS} || #{root} #{href} #{VLC_ARGS} || #{home} #{href} #{VLC_ARGS}", (error, stdout, stderror) ->
            if (error) 
                process.exit(0)
stream = (torrent) ->
    engine = peerflix(torrent,{dht: false, id: '01234567890123456789'})
    engine.on 'ready', ->
        href = "http://localhost:#{engine.server.address().port}/"
        # href = "http://#{address()}:#{engine.server.address().port}/"
        console.log href
        engine.server.on 'error', ->
            console.log "SRV ERROR"
        engine.on 'peer', ->
            console.log "connected to peer"
        engine.server.on 'listening', ->
            # console.log engine.server.index
            startVlc(href)
            # vlc.on 'exit', ->
            #   process.exit(0) if not argv.n and argv.quit isnt false