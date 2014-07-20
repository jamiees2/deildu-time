###
Module dependencies
###
express = require("express")

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
	res.json({hello: 'world22'})
exports.indexRouter = indexRouter
