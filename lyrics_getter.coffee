root = exports ? this

http_get = require 'http-get'
$ = require 'jQuery'

redis = require 'redis'
client = redis.createClient()

lastDownloadTimestamp = 0

downloadRateLimited = (url, callback) ->
  timestamp = Math.round((new Date()).getTime() / 1000)
  if lastDownloadTimestamp + 1 >= timestamp
    setTimeout(() ->
      downloadRateLimited(url, callback)
    , 1000)
  else
    lastDownloadTimestamp = timestamp
    req_headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 6.2; WOW64; rv:16.0.1) Gecko/20121011 Firefox/16.0.1'}
    http_get.get({'url': url, 'headers': req_headers}, (err, response) ->
      data = response.buffer
      client.set('cachedurl|' + url, data)
      callback(data)
    )

cachedDownloadRateLimited = (url, callback) ->
  client.get('cachedurl|' + url, (err, reply) ->
    if reply?
      callback(reply)
    else
      downloadRateLimited(url, (data) ->
        client.set('cachedurl|' + url, data)
        callback(data)
      )
  )

root.getTitleLyricsVideoFromURL = (url, callback) ->
  await
    cachedDownloadRateLimited(url, defer(data))
  await
    root.getTitleFromURL(url, defer(title))
    root.getLyricsFromURL(url, defer(lyrics))
    root.getVideoFromURL(url, defer(video))
  callback(title, lyrics, video)

root.getLyricsFromURL = (url, callback) ->
  url = url.trim().split('\t').join('')
  if url.indexOf('http://mp3.zing.vn/bai-hat/') == 0
    cachedDownloadRateLimited(url, (data) ->
      lyrics = $(data).find('._lyricContent').text()
      callback(lyrics)
    )

root.getTitleFromURL = (url, callback) ->
  url = url.trim().split('\t').join('')
  if url.indexOf('http://mp3.zing.vn/bai-hat/') == 0
    cachedDownloadRateLimited(url, (data) ->
      title = $(data).find('.detail-title').text()
      callback(title)
    )

root.getVideoFromURL = (url, callback) ->
  url = url.trim().split('\t').join('')
  if url.indexOf('http://mp3.zing.vn/bai-hat/') == 0
    cachedDownloadRateLimited(url, (data) ->
      for line in data.split('\n')
        line = line.trim().split('\t').join('')
        if line.indexOf('mp3: "http://mp3.zing.vn/html5/song/') == 0
          line = line[6...-1]
          callback(line)
    )

main = ->
  url = 'http://mp3.zing.vn/bai-hat/Em-Yeu-Anh-Luong-Bich-Huu/ZWZFUD87.html'
  if process.argv[2]?
    url = process.argv[2]
  root.getTitleLyricsVideoFromURL(url, (title, lyrics, video) ->
    console.log lyrics
    console.log video
    console.log title
  )
  ###
  root.getLyricsFromURL(url, (lyrics) ->
    console.log lyrics
  )
  root.getVideoFromURL(url, (video) ->
    console.log video
  )
  root.getTitleFromURL(url, (video) ->
    console.log video
  )
  ###

main() if require.main is module

