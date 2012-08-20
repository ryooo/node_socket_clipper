mongoose = require("mongoose")
db = mongoose.connect("mongodb://localhost:27017/kurukuma")
Schema = mongoose.Schema

User = new Schema(
  id:
    type: String
    index: true
  created: Date
  updated: Date
  oauth:
    token: String
    token_secret: String
    verifier: String
    access_token: String
    access_token_secret: String
  info: {}
  user_profile: 
    user_id: String
    screen_name: String
)
User.pre "save", (next) ->
  @created = new Date()  if @isNew
  @updated = new Date()
  next()

module.exports = db.model("User", User)
