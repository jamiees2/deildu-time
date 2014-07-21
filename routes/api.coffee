###
Module dependencies
###
express = require("express")
request = require("request")
FormData = require('form-data')
cheerio = require('cheerio')
iconv = require('iconv')
peerflix = require('peerflix')
address = require('network-address')
hat = require('hat')
parseTorrent = require('parse-torrent')


secrets = require("../secrets")

API_HOST = "http://deildu.net"

request = request.defaults
	jar: true
	encoding: null
	headers:
		'User-Agent': 'Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2049.0 Safari/537.36'

buildForm = (data, callback) ->
	form = new FormData()
	for key, val of data
		form.append(key, val)
	form.getLength (_,len) ->
		callback(_,len,form)


login = (callback) ->
	buildForm secrets.deildu, (_,len,form) ->
		r = request.post("#{API_HOST}/takelogin.php", {headers: {'Content-Length': len}}, (loginErr, loginResponse) ->
			if loginErr
				console.log loginErr
				return
			callback()
		)
		r._form = form

toUtf8 = (body) ->
	return new iconv.Iconv('iso-8859-1', 'utf-8').convert(body).toString('utf-8')
# TODO: save cookie somewhere to log in again
# TODO: handle login redirect errors
login -> # Login immediately
	request.get "#{API_HOST}/download.php/170985/Last.Week.Tonight.With.John.Oliver.S01E11.HDTV.XviD-AFG.torrent", (err, httpResponse, body) ->
		if err
			console.log err
			return res.json({error: true})
		console.log parseTorrent(body)
		engine = peerflix(body,{index: 0, dht: false, id: '01234567890123456789'})
		oldemit = engine.emit
		engine.emit = ->
			console.log arguments
			oldemit.apply(engine, arguments)
		href = 'http://'+address()+':'+9997+'/';
		filename = engine.server.index.name.split('/').pop().replace(/\{|\}/g, '');
		filelength = engine.server.index.length;
		console.log href
		engine.server.on 'error', ->
			console.log "SRV ERROR"
		engine.on 'error', ->
			console.log "ERROR"
		engine.on 'downloaded', ->
			console.log engine.swarm.downloaded
		engine.on 'peer', (addr) ->
			console.log addr

apiRouter = express.Router()

apiRouter.route("/api/list").all (req, res) ->
	res.set({ 'content-type': 'application/json; charset=utf-8' })
	request.get "#{API_HOST}/browse.php", (err, httpResponse, body) ->
		if err
			console.log err
			return res.json({error: true})
		body = toUtf8(body)
		$ = cheerio.load(body)
		data = []
		$('.torrentlist tr:not(:first-child)').each ->
			$this = $(@)
			$td = $this.find('td')
			if $td.length > 1

				td = []
				$td.each ->
					td.push($(this))
				obj = 
					id: td[1].find('a').attr('href').substr('details.php?id='.length)
					category: td[0].find('a img').attr('alt')#.substr('/pic/2/'.length).slice(0,-4).replace(/[0-9]/g,'')
					name: td[1].text().trim()
					file_count: td[3].text().trim()
					# ignore comments
					date: td[5].text().trim()
					size: td[6].text().trim()
					# ignore users downloaded
					seeders: td[8].text().trim()
					leechers: td[9].text().trim()
					user: td[10].text().trim()
				obj.torrent = td[2].find('a').attr('href')
				obj.torrent = obj.torrent.substr(obj.torrent.lastIndexOf('/') + 1)

				data.push(obj)
		res.json(data)
apiRouter.route("/api/details/:id").all (req, res) ->
	res.set({ 'content-type': 'application/json; charset=utf-8' })
	request.get "#{API_HOST}/details.php?id=#{req.params.id}", (err, httpResponse, body) ->
		if err
			console.log err
			return res.json({error: true})

		body = toUtf8(body)
		$ = cheerio.load(body)
		$td = $('#columns table:first-of-type tr td:not(.rowhead):not(.heading)')
		td = []
		$td.each ->
			td.push($(this))
		obj = 
			title: $('#columns h1').text()
			torrent: td[0].text().trim()
			info_hash: td[1].text().trim()
			description: td[2].html()
			type: td[3].text().trim()
			last_seeder: td[4].text().trim()
			size: td[5].text().trim()
			added: td[6].text().trim()
			# ignore views
			# ignore hits
			# ignore snatched
			user: td[10].text().trim()
			file_count: parseInt(td[11].text().trim())
		sharers = td[12].text().trim().split('=')[0].split(',')
		obj.seeders = parseInt(sharers[0])
		obj.leechers = parseInt(sharers[1])
		res.json obj
engine = null
apiRouter.route("/api/download/:id/:torrent").all (req, res) ->
	res.set({ 'content-type': 'application/json; charset=utf-8' })
	request.get "#{API_HOST}/download.php/#{req.params.id}/#{req.params.torrent}", (err, httpResponse, body) ->
		if err
			console.log err
			return res.json({error: true})
		engine = peerflix(body,{port: 9997,index: 0, dht: false})
		href = 'http://'+address()+':'+9997+'/';
		filename = engine.server.index.name.split('/').pop().replace(/\{|\}/g, '');
		filelength = engine.server.index.length;

		res.json({success: true, server: href})




exports.router = apiRouter
