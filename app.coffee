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

lyrics_getter = require './lyrics_getter'

http_get = require 'http-get'

redis = require 'redis'
rclient = redis.createClient()

toSeconds = (time) ->
  time = time.split(',').join('.')
  [hour,min,sec] = time.split(':')
  hour = parseFloat(hour)
  min = parseFloat(min)
  sec = parseFloat(sec)
  return hour*3600 + min*60 + sec

###
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
###

subtitleread = require './subtitleread'
subtitleread_plain = require './subtitleread_plain'

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

#root.subtitleText = getSubtitles()
root.subtitleText = fs.readFileSync('alltherightmoves.txt', 'utf8')
root.subtitleGetter = new subtitleread_plain.SubtitleRead(root.subtitleText)
everyone.now.subtitleLines = (x.split(' ') for x in root.subtitleGetter.subtitles)
everyone.now.gwordidx_to_lineidx = root.subtitleGetter.gwordidx_to_lineidx
everyone.now.gwordidx_to_wordidx = root.subtitleGetter.gwordidx_to_wordidx

getSubAtTime = (time, callback) ->
  #sub = root.subtitleGetter.subtitleAtTime(time + 30.6)
  sub = root.subtitleGetter.subtitleAtTime(time)
  console.log(sub)
  callback(sub)

getSubAtIndex = (lineidx, callback) ->
  #sub = root.subtitleGetter.subtitleAtTime(time + 30.6)
  sub = root.subtitleGetter.subtitleAtIndex(lineidx)
  gwordidx = root.subtitleGetter.togwordidx(0, lineidx)
  console.log(sub)
  callback(sub, gwordidx)

everyone.now.getSubAtTime = getSubAtTime
everyone.now.getSubAtIndex = getSubAtIndex

root.songname = 'Default Artist - Default Song'
root.videourl = ''

everyone.now.sendPlayingSongId = (id) ->
  if everyone.now.singerReceivesSongId?
    everyone.now.singerReceivesSongId(id)

everyone.now.sendPlayingSongVideo = singerReceivesSongVideo = (videourl) ->
  if everyone.now.singerReceivesSongVideo?
    everyone.now.singerReceivesSongVideo(videourl)

everyone.now.sendPlayingSongName = sendPlayingSongName = (songname) ->
  root.songname = songname
  if everyone.now.singerReceivesSongName?
    everyone.now.singerReceivesSongName(songname)

everyone.now.getGwordIdxMaps = (callback) ->
  callback(root.subtitleGetter.gwordidx_to_lineidx, root.subtitleGetter.gwordidx_to_wordidx, root.subtitleGetter.gwordidx_to_linestart)

everyone.now.sendWordHighlightedToServer = (idx, lineidx, currentTime, iscorrect) ->
  if everyone.now.singerReceivesHighlightedWord?
    everyone.now.singerReceivesHighlightedWord(idx, iscorrect)
  if idx < 0 or idx >= everyone.now.subtitleLines[lineidx].length
    return
  gwordidx = root.subtitleGetter.togwordidx(idx, lineidx)
  console.log "idx: #{idx}, lineidx: #{lineidx}, gwordidx: #{gwordidx}"
  currentTimeRoundedToQsec = Math.round(currentTime * 4.0)/4.0
  console.log 'ik|' + root.videourl + '|tqsec' + currentTimeRoundedToQsec + '|' + gwordidx
  rclient.hincrby('ik|' + root.videourl + '|tqsec' + currentTimeRoundedToQsec, gwordidx, 1)

everyone.now.getTimingInfoForSong = (videourl, videolength, callback) ->
  console.log("started getting timing info")
  numwords = root.subtitleGetter.numwords
  time_to_gwordnum_count = []
  for i in [0..Math.round(4.0 * videolength)]
    time_to_gwordnum_count[i] = []
    for gwordidx in [0..numwords]
      time_to_gwordnum_count[i][gwordidx] = 0
  await
    for i in [0..Math.round(4.0 * videolength)]
      fetchcounts = (li, lcallback) ->
        currentTimeRoundedToQsec = li / 4.0
        rclient.hgetall('ik|' + videourl + '|tqsec' + currentTimeRoundedToQsec, (err, data) ->
          counts = (0 for x in [0..numwords])
          #console.log data
          if data?
            for gwordidx in [0..numwords]
              if data[gwordidx]?
                counts[gwordidx] = parseInt(data[gwordidx])
          lcallback(counts)
        )
      fetchcounts(i, defer(time_to_gwordnum_count[i]))
  ###
  await
    for i in [0..Math.round(4.0 * videolength)]
      time_to_gwordnum_count[i] = []
      for gwordidx in [0..numwords]
        fetchcount = (li, lgwordidx, lcallback) ->
          currentTimeRoundedToQsec = li / 4.0
          rclient.hget('ik|' + videourl + '|tqsec' + currentTimeRoundedToQsec, gwordidx, (err, data) ->
            if data?
              count = parseInt(data)
              lcallback(count)
            else
              lcallback(0)
          )
        fetchcount(i, gwordidx, defer(time_to_gwordnum_count[i][gwordidx]))
  ###
  
  #console.log time_to_gwordnum_count
  console.log("finished getting timing info")
  callback(time_to_gwordnum_count)

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
      subtitles += starttime + ' --> ' + endtime + '\n'
      subtitles += $(x).text() + '\n'
      subtitles += '\n'
    root.subtitleText = subtitles
    root.subtitleGetter = new subtitleread.SubtitleRead(root.subtitleText)
    callback(subtitles)

everyone.now.sendVideoControl = (command) ->
  if everyone.now.singerReceivesVideoControl?
    everyone.now.singerReceivesVideoControl(command)

everyone.now.sendWordsToServer = (words, lineidx, gwordidxoffset) ->
  if everyone.now.singerReceivesWords?
    everyone.now.singerReceivesWords(words, lineidx, gwordidxoffset)

everyone.now.setSearchBox = (url, callback) ->
  lyrics_getter.getTitleLyricsVideoFromString(url, (title, lyrics, videourl) ->
    root.songname = title
    root.videourl = videourl
    root.subtitleText = lyrics
    root.subtitleGetter = new subtitleread_plain.SubtitleRead(root.subtitleText)
    everyone.now.subtitleLines = (x.split(' ') for x in root.subtitleGetter.subtitles)
    everyone.now.gwordidx_to_lineidx = root.subtitleGetter.gwordidx_to_lineidx
    everyone.now.gwordidx_to_wordidx = root.subtitleGetter.gwordidx_to_wordidx
    sendPlayingSongName(title)
    singerReceivesSongVideo(videourl)
    callback(title, lyrics, videourl)
  )

everyone.now.connectNewSinger = () ->
  sendPlayingSongName(root.songname)
  singerReceivesSongVideo(root.videourl)

everyone.now.getTitleLyricsVideoFromString = lyrics_getter.getTitleLyricsVideoFromString
everyone.now.getLyricsFromURL = lyrics_getter.getLyricsFromURL
everyone.now.getVideoFromURL = lyrics_getter.getVideoFromURL

everyone.now.getToken = (callback) ->
  #key = '21484962';    // Replace with your API key  
  #secret = '1d3cac96fdbd675a881c6f59b1774408c75d903d';  // Replace with your API secret  
  #opentok = new OpenTok.OpenTokSDK(key, secret);
  token = 'T1==cGFydG5lcl9pZD0yMTQ4NDk2MiZzaWc9MDZlYzRlOTYwYzE4NjIwY2YxNzE5OGM5MWE4ODMxYjZhZWRlZjkzNTpzZXNzaW9uX2lkPTJfTVg0eU1UUTRORGsyTW41LVUyRjBJRTV2ZGlBeE1DQXhOem96TURvd01TQlFVMVFnTWpBeE1uNHdMalk1TkRjMk9UUi0mY3JlYXRlX3RpbWU9MTM1MjYwNzExOSZleHBpcmVfdGltZT0xMzU1MTk5MTE5JnJvbGU9cHVibGlzaGVyJmNvbm5lY3Rpb25fZGF0YT0mbm9uY2U9NTI4MjAy' # Replace with a generated token. See http://static.opentok.com/opentok/api/tools/generator
  callback(token)
