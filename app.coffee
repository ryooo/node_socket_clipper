
###
Module dependencies.
###
express = require("express")
app = module.exports = express.createServer()

# Configuration
app.configure ->
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.bodyParser()
  app.use express.cookieParser()
  app.use express.session({ secret: "Totokun-1" })
  app.use express.methodOverride()
  app.use app.router
  app.use express.cookieParser()
  app.use express.static(__dirname + "/public")


app.dynamicHelpers {
  session: (req, res) ->
    return req.session
}

app.configure "development", ->
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )

app.configure "production", ->
  app.use express.errorHandler()


# Routes
routes = require("./routes")
app.get "/", routes.index
app.post "/messages/annotations", routes.messages.annotations
app.get "/messages/search", routes.messages.search
app.put "/messages/annotations", routes.messages.update
app.delete "/messages/annotations", routes.messages.delete
app.get "/auth/twitter", routes.auth.twitter
app.get "/auth/twitter/callback", routes.auth.callback

app.listen 3000, ->
  console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env


#socketio = require('socket.io').listen(app);
