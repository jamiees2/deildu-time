
peerflix = require('./lib/peerflix')
address = require('network-address')
hat = require('hat')
parseTorrent = require('parse-torrent')
fs = require('fs')
proc = require('child_process')






torrent = fs.readFileSync(__dirname + '/torrents/test2.torrent')


# console.log parseTorrent(torrent)
engine = peerflix(torrent,{dht: false, id: '01234567890123456789'})
VLC_ARGS = "-q --video-on-top --play-and-exit"
engine.on 'ready', ->
	href = "http://localhost:#{engine.server.address().port}/"
	# href = "http://#{address()}:#{engine.server.address().port}/"
	console.log href

	engine.server.on 'error', ->
		console.log "SRV ERROR"
	engine.on 'peer', ->
		console.log "peer"
	engine.server.on 'listening', ->
		# console.log engine.server.index
		root = '/Applications/VLC.app/Contents/MacOS/VLC'
		home = (process.env.HOME || '') + root
		vlc = proc.exec "vlc #{href} #{VLC_ARGS} || #{root} #{href} #{VLC_ARGS} || #{home} #{href} #{VLC_ARGS}", (error, stdout, stderror) ->
			if (error) 
				process.exit(0)
