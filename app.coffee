fs = require 'fs'
express = require 'express'
app = express()
http = require 'http'
httpserver = http.createServer(app)
httpserver.listen(3000)
nowjs = require 'now'
everyone = nowjs.initialize(httpserver)

subtitleread = require './subtitleread'

app.configure('development', () ->
  app.use(express.errorHandler())
)

app.configure( ->
  app.set('views', __dirname + '/views')
  app.set('view engine', 'ejs')
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.set('view options', { layout: false })
  app.locals({ layout: false })
  app.use(express.static(__dirname + '/'))
)

subtitleText = fs.readFileSync('alltherightmoves.srt', 'utf8')
subtitleGetter = new subtitleread.SubtitleRead(subtitleText)

getSubAtTime = (time, callback) ->
  sub = subtitleGetter.subtitleAtTime(time)
  console.log(sub)
  callback(sub)

everyone.now.getSubAtTime = getSubAtTime

everyone.now.sendWordsToServer = (words) ->
  everyone.now.singerReceivesWords(words)

everyone.now.getToken = (callback) ->
  #key = '21484962';    // Replace with your API key  
  #secret = '1d3cac96fdbd675a881c6f59b1774408c75d903d';  // Replace with your API secret  
  #opentok = new OpenTok.OpenTokSDK(key, secret);
  token = 'T1==cGFydG5lcl9pZD0yMTQ4NDk2MiZzaWc9MDZlYzRlOTYwYzE4NjIwY2YxNzE5OGM5MWE4ODMxYjZhZWRlZjkzNTpzZXNzaW9uX2lkPTJfTVg0eU1UUTRORGsyTW41LVUyRjBJRTV2ZGlBeE1DQXhOem96TURvd01TQlFVMVFnTWpBeE1uNHdMalk1TkRjMk9UUi0mY3JlYXRlX3RpbWU9MTM1MjYwNzExOSZleHBpcmVfdGltZT0xMzU1MTk5MTE5JnJvbGU9cHVibGlzaGVyJmNvbm5lY3Rpb25fZGF0YT0mbm9uY2U9NTI4MjAy' # Replace with a generated token. See http://static.opentok.com/opentok/api/tools/generator
  callback(token)
