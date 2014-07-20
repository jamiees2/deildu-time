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
indexRouter.route("/api/list").all (req,res) ->
	request "http://deildu.net/browse.php", (err, httpResponse, body) ->
		res.send(body) # TODO: parse list out of body

exports.indexRouter = indexRouter
