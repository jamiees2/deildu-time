parseTorrent = require('parse-torrent')
peerflix = require('peerflix')
address = require('network-address')

class Torrent extends Backbone.Model
	initialize: (opts) ->
		try
			torrent = parseTorrent(opts.torrent)
		catch e
			console.log e
		@set(_.pick(torrent,'infoHash','name','private','created','announce'))
		# @engine = opts.engine
		@opts = 
			dht: false
			id: '01234567890123456789'
		@opts.tmp = localStorage['downloads'] if localStorage['downloads']?
		@engine = peerflix(opts.torrent, @opts)
		@hotswaps = 0
		@verified = 0
		@invalid = 0
		@listening = false

		@engine.on 'verify', @verify
		@engine.on 'invalid-piece', @invalid_piece
		@engine.on 'hotswap', @hotswap
		@engine.on 'peer', @peer
		@engine.on 'idle', @idle
		@engine.on 'ready', @engineReady
		@engine.server.on 'listening', @serverReady

		@on "remove", @removeFiles
		@on "stop", @stopDownloading
	engineReady: =>
		console.log "Engine ready"
		@set
        	localHref: "http://localhost:#{@engine.server.address().port}/"
        	remoteHref:"http://#{address()}:#{@engine.server.address().port}/"
        	port: @engine.server.address().port
        @startInterval()
	startInterval: ->
		@interval = setInterval(@updateStatus,250)

	serverReady: =>
		@listening = true
		@trigger('server:ready')
	updateStatus: =>
		unchoked = @engine.swarm.wires.filter(@active)
		@trigger "status:update", unchoked, @engine.swarm.wires, @engine.swarm

	active: (wire) =>
		return not wire.peerChoking

	verify: =>
		@verified++
		@engine.swarm.piecesGot += 1

	idle: =>
		@idle = true
		# console.log 'idle'


	invalid_piece: =>
		@invalid++

	hotswap: =>
		@hotswaps++

	peer: =>

	removeFiles: (cb) ->
		cb = cb or ->
		@engine.remove(cb)

	stopDownloading: (cb) ->
		cb = cb or ->
		@engine.server.close() if @listening
		@engine.destroy(cb)



exports.Torrent = Torrent