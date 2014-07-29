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
		@engine = peerflix(opts.torrent,{dht: false, id: '01234567890123456789', port: 8090})
		@hotswaps = 0
		@verified = 0
		@invalid = 0

		@engine.on 'verify', @verify
		@engine.on 'invalid-piece', @invalid_piece
		@engine.on 'hotswap', @hotswap
		@engine.on 'peer', @peer
		@engine.on 'idle', @idle
		@engine.on 'ready', @engineReady
		@engine.server.on 'listening', @serverReady
	engineReady: =>
		console.log "Engine ready"
		@set
        	localHref: "http://localhost:#{@engine.server.address().port}/"
        	remoteHref:"http://#{address()}:#{@engine.server.address().port}/"
        @startInterval()
	startInterval: ->
		@interval = setInterval(@updateStatus,250)

	serverReady: =>
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



exports.Torrent = Torrent