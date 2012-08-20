mongoose = require("mongoose")
db = mongoose.connect("mongodb://localhost:27017/kurukuma")
Schema = mongoose.Schema
Message = new Schema(
  id:
    type: String
    index: true

  annotator_schema_version:
    type: String
    default: "v1.0"

  created: Date
  updated: Date
  text: String
  quote: String
  uri: String
  ranges: [
    start: String
    end: String
    startOffset: Number
    endOffset: Number
  ]
  user_id: String
  consumer: String
  tags: []
  permissions:
    read: []
    admin: []
    update: []
    delete: []
)
Message.pre "save", (next) ->
  @created = new Date()  if @isNew
  @updated = new Date()
  next()

module.exports = db.model("Message", Message)
