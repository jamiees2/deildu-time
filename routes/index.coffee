###
Module dependencies
###
express = require("express")
request = require("request")
request = request.defaults
	jar: true
	headers:
		'User-Agent': 'Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2049.0 Safari/537.36'
FormData = require('form-data')
cheerio = require('cheerio')


secrets = require("../secrets")

getLength = (data, callback) ->
	form = new FormData()
	console.log data
	for key, val of data
		form.append(key, val)
	form.getLength (_,len) ->
		callback(_,len,form)

login = ->
	getLength secrets.deildu, (_,len,form) ->
		r = request.post("http://deildu.net/takelogin.php", {headers: {'content-length': len}}, (loginErr, loginResponse) ->
			if loginErr
				console.log loginErr
				return
			# console.log loginResponse.statusCode
			# console.log loginResponse.headers
		)
		r._form = form
login() # Initialize the connection immediately
###
the new Router exposed in express 4
the indexRouter handles all requests to the `/` path
###
indexRouter = express.Router()

###
this accepts all request methods to the `/` path
###
indexRouter.route("/").all (req, res) ->
  res.render "index",
    title: "deildu-time"

  return
indexRouter.route("/api/list").all (req, res) ->
	request.get "http://deildu.net/browse.php", (err, httpResponse, body) ->
		if err
			return res.json({error: true})
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
					category: td[0].find('a img').attr('src').substr('/pic/2/'.length).slice(0,-4).replace(/[0-9]/g,'')
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
indexRouter.route("/api/details/:id").all (req, res) ->
	request.get "http://deildu.net/details.php?id=#{req.params.id}", (err, httpResponse, body) ->
		if err
			return res.json({error: true})

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
			# ignore type TODO: for now
			last_seeder: td[4].text().trim()
			size: td[5].text().trim()
			added: td[6].text().trim()
			# ignore views
			# ignore hits
			# ignore snatched
			user: td[10].text().trim()
			file_count: td[11].text().trim()
			sharers: td[12].text().trim()

		res.json obj


exports.indexRouter = indexRouter
