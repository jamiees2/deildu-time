###
Module dependencies.
###
express = require("express")
path = require("path")
logger = require("morgan")
bodyParser = require("body-parser")
compress = require("compression")
favicon = require("static-favicon")
methodOverride = require("method-override")
errorHandler = require("errorhandler")
config = require("./config")
fs = require("fs")
app = express()

###
Express configuration.
###
app.set "port", config.server.port
app.set "views", path.join(__dirname, "views")
app.set "view engine", "jade"
app
	.use(compress())
	.use(favicon())
	.use(logger("dev"))
	.use(bodyParser())
	.use(methodOverride())
	.use(express.static(path.join(__dirname, "public")))
	# .use(routes.indexRouter)
fs.readdirSync("./routes").forEach (file) ->
  app.use(require("./routes/" + file).router);

app.use (req, res) ->
	res.status(404).render "404",
		title: "Not Found :("

app.use errorHandler()  if app.get("env") is "development"
app.listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
  return

