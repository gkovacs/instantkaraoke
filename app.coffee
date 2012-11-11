fs = require 'fs'
express = require 'express'
app = express()
http = require 'http'
httpserver = http.createServer(app)
httpserver.listen(6666)
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