Message = require("../models/message")
User = require("../models/user")

# ---------------------
# home
# ---------------------
exports.index = (req, res) ->
  res.render "index",
    title: "Express"

# ---------------------
# Message
# ---------------------
class MessageController
  
  actions: ->
    return {
      annotations: @annotations
      search: @search
      update: @update
      delete: @delete
    }
  
  annotations: (req, res) ->
    # 認証
    if typeof req.session.user_profile is 'undefined'
      return res.redirect('/auth/twitter')
    User.findOne {id: req.session.user_profile.user_id}, (err, user) ->
      if user is null || typeof user is 'undefined'
        return res.redirect('/auth/twitter')
      else
        # 登録
        row = new Message(req.body)
        row.user_id = user.id
        
        ret = row.save (err) ->
          if err is null
            res.send({})
          else
            console.log "Err:" + err
  
  search: (req, res) ->
    query = Message.find {uri: req.query.uri}
    query.desc('updated')
    query.limit(req.query.limit)
    query.exec (err, docs) ->
      ret = {
        rows: docs
      }
      res.send(ret)
  
  delete: (req, res) ->
    # 認証
    if typeof req.session.user_profile is 'undefined'
      return res.redirect('/auth/twitter')
    User.findOne {id: req.session.user_profile.user_id}, (err, user) ->
      if user is null || typeof user is 'undefined'
        return res.redirect('/auth/twitter')
      else
        Message.findById req.body._id, (err, row) ->
          if row.user_id is user.id
            row.remove()
    
  update: (req, res) ->
    # 認証
    if typeof req.session.user_profile is 'undefined'
      return res.redirect('/auth/twitter')
    User.findOne {id: req.session.user_profile.user_id}, (err, user) ->
      if user is null || typeof user is 'undefined'
        return res.redirect('/auth/twitter')
      else
        Message.findById req.body._id, (err, row) ->
          if row.user_id is user.id
            row.text = req.body.text
            ret = row.save (err) ->
              if err is null
                res.send({})
              else
                console.log "Err:" + err
  
exports.messages = (new MessageController()).actions()

# ---------------------
# Twitter認証
# ---------------------
class TwitterController
  constructor: ->
    @oauth = require('oauth')
    @_twitterConsumerKey = "GvwdaKqJEz1GvPHajM3SZw";
    @_twitterConsumerSecret = "bhlMUCQuhoXFF1UBusb4w0f3rMGNaGpm0Hy2yNC52w";
  consumer: =>
    return new @oauth.OAuth(
      "https://twitter.com/oauth/request_token",
      "https://twitter.com/oauth/access_token",
      @_twitterConsumerKey,
      @_twitterConsumerSecret,
      "1.0A",
      "http://localhost:3000/auth/twitter/callback/", "HMAC-SHA1")
      
  actions: ->
    return {
      twitter: @twitter
      callback: @callback
    }

  twitter: (req, res) =>
    @consumer().getOAuthRequestToken (error, oauth_token, oauth_token_secret, results) ->
      if error
        res.send(error)
      else
        req.session.oauth = {};
        req.session.oauth.token = oauth_token;
        req.session.oauth.token_secret = oauth_token_secret;
        res.redirect('https://twitter.com/oauth/authenticate?oauth_token=' + oauth_token);
  
  callback: (req, res) =>
    if req.session.oauth
      req.session.oauth.verifier = req.query.oauth_verifier;
      @consumer().getOAuthAccessToken(
        req.session.oauth.token,
        req.session.oauth.token_secret,
        req.session.oauth.verifier,
        (error, oauth_access_token, oauth_access_token_secret, results) ->
          if error
            res.send(error);
          else
            req.session.oauth.access_token = oauth_access_token
            req.session.oauth.access_token_secret = oauth_access_token_secret
            req.session.user_profile = results
            # User情報 - 更新
            User.findOne {id: req.session.user_profile.user_id}, (err, user) ->
              if user is null || typeof user is 'undefined'
                user = new User()
                user.id = req.session.user_profile.user_id
                user.oauth = req.session.oauth
                user.user_profile = req.session.user_profile
              http = require('http');
              http.get({
                host: 'api.twitter.com'
                path: '/1/users/show/' + user.id + '.json'
              }, (twRes) ->
                body = ''
                twRes.on 'data', (chunk)->
                  body += chunk.toString()
                  
                twRes.on 'end', ()->
                  user.info = JSON.parse(body)
                  user.save()
                  res.redirect('/')
              )
        )
exports.auth = (new TwitterController()).actions()