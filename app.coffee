fs = require 'fs'
request = require 'request'
$ = require 'jQuery'
client = require './client'

express = require 'express'
app = express()
http = require 'http'
httpserver = http.createServer(app)
httpserver.listen(1234)
nowjs = require 'now'
everyone = nowjs.initialize(httpserver)

toSeconds = (time) ->
  time = time.split(',').join('.')
  [hour,min,sec] = time.split(':')
  hour = parseFloat(hour)
  min = parseFloat(min)
  sec = parseFloat(sec)
  return hour*3600 + min*60 + sec

getSubtitles = ->
  xmltext = fs.readFileSync('alltherightmoves.xml', 'utf8')
  subtitles = ""
  for x in $(xmltext).find('line')
    if $(x).text() == ''
      continue
    starttime = '00:' + $(x).attr('lrc_timestamp').replace('[', '').replace(']', '')
    starttimesecs = toSeconds(starttime)
    endtimesecs = parseFloat($(x).attr('milliseconds')) / 1000.0
    [hour,min,sec,millisec] = client.toHourMinSecMillisec(endtimesecs)
    endtime = hour + ':' + min + ':' + sec + '.' + millisec
    subtitles += starttime + ' --> ' + endtime + "\n"
    subtitles += $(x).text() + "\n"
    subtitles += '\n'
  return subtitles

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

root.subtitleText = getSubtitles()
root.subtitleGetter = new subtitleread.SubtitleRead(root.subtitleText)

getSubAtTime = (time, callback) ->
  sub = root.subtitleGetter.subtitleAtTime(time + 31)
  console.log(sub)
  callback(sub)

everyone.now.getSubAtTime = getSubAtTime

everyone.now.sendWordHighlightedToServer = (idx) ->
  everyone.now.singerReceivesHighlightedWord(idx)

everyone.now.searchTrack = (query, callback) ->
  api = require '7digital-api'
  tracks = new api.Tracks()
  
  tracks.search({q: query}, (err, data) ->
    callback(data)
  )

everyone.now.requestPreview = (id, callback) ->
  api = require '7digital-api'
  tracks = new api.Tracks()
  
  tracks.getPreview({
      trackId: id,
      oauth_consumer_key: 'musichackday'
  }, (err, data) ->
    callback(data)
  )

everyone.now.requestSubtitles = (isrc, callback) ->
  request.get { uri:"http://test.lyricfind.com/api_service/lyric.do?apikey=2233d1d669999ce64ee0eb073d6da191&lrckey=d34e7a583d25d753361d0b60d423e35b&reqtype=default&trackid=isrc:#{encodeURI(isrc)}&format=lrc"}, (err, r, body) ->
    xmltext = body
    subtitles = ""
    for x in $(xmltext).find('line')
      if $(x).text() == ''
        continue
      starttime = '00:' + $(x).attr('lrc_timestamp').replace('[', '').replace(']', '')
      starttimesecs = toSeconds(starttime)
      endtimesecs = parseFloat($(x).attr('milliseconds')) / 1000.0
      [hour,min,sec,millisec] = client.toHourMinSecMillisec(endtimesecs)
      endtime = hour + ':' + min + ':' + sec + '.' + millisec
      subtitles += starttime + ' --> ' + endtime + "\n"
      subtitles += $(x).text() + "\n"
      subtitles += '\n'
    root.subtitleText = subtitles
    root.subtitleGetter = new subtitleread.SubtitleRead(root.subtitleText)
    callback(subtitles)

everyone.now.sendWordsToServer = (words) ->
  everyone.now.singerReceivesWords(words)
