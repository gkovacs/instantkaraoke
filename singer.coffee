root = exports ? this

replaceAll = (str, from, to) ->
  return str.split(from).join(to)

escapeHtmlQuotes = (str) ->
  replacements = [['&', '&amp;'], ['>', '&gt;'], ['<', '&lt;'], ['"', '&quot;'], ["'", '&#8217;']]
  for [from,to] in replacements
    str = replaceAll(str, from, to)
  return str

"""
root.fixElementPosition = fixElementPosition = (idx) ->
  setTimeout( () ->
    offset = $('#ws' + idx).offset()
    console.log offset
    origLeft = offset.left
    origTop = offset.top
    $('#ws' + idx).css('position', 'absolute')
    #setTimeout(() ->
    #$('#ws' + idx).offset({left: origLeft, top: origTop})
    #, 100)
    $('#ws' + idx).css('left': offset.left)
    $('#ws' + idx).css('top': offset.top)
  , 100)
"""

getUrlParameters = () ->
  map = {};
  parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, (m,key,value) ->
    map[key] = value
  )
  return map

root.showplayer = false
root.singleplayer = false

$(document).ready( ->
  params = getUrlParameters()
  if params['showplayer']?
    root.showplayer = true
    $('video').show()
  if params['singleplayer']?
    root.singleplayer = true
    root.showplayer = true
    $('video').show()
)

root.words = []
root.time_to_gwordnum = []
root.lineidx = 0
root.gwordidxoffset = 0

gwordidxToLocalIdx = (gwordidx) ->
  if gwordidx < root.gwordidxoffset or gwordidx > root.gwordidxoffset + root.words.length
    return -1
  return gwordidxoffset - root.gwordidxoffset

now.singerReceivesVideoControl = (command) ->
  if not root.showplayer
    return
  if command == 'start'
    $('video')[0].play()
  else if command == 'pause'
    $('video')[0].pause()

now.singerReceivesHighlightedWord = singerReceivesHighlightedWord = (idx, iscorrect) ->
  $(".lyric").css('color', 'black')
  for i in [idx+1...root.words.length]
    $('#ws' + i).css('color', 'grey')
  $('#ws' + (idx-1)).animate({
    'top': '30px'
  }, 100)
  $(".lyric").css('font-size', '20px')
  if iscorrect
    $('#ws' + idx).css('color', 'green')
  #$('#ws' + idx).css('top', '30px')
  #$('#ws' + idx).css('font-size', '40px')
  $('#ws' + idx).animate({
    'top': '0px'
  }, 100)

now.singerReceivesWords = singerReceivesWords = (words, lineidx, gwordidxoffset) ->
  #root.words = words
  lidx = now.gwordidx_to_lineidx[gwordidxoffset]
  root.words = now.subtitleLines[lidx]
  root.gwordidxoffset = gwordidxoffset
  $('#lyricsDisplay').html('')
  for word,i in root.words
    $('#lyricsDisplay').append("<span style='position: relative; top: 30px; margin-right: 8px; color: grey; font-size: 20px' id='ws#{i}' class='lyric'> " + word + " </span>")
    #fixElementPosition(i)
  #$('#ws0').css('color', 'grey')

root.prevGwordIdx = -1

root.onTimeChanged = (vid) ->
  if not root.singleplayer
    return
  time = Math.round(vid.currentTime * 4.0)
  #console.log time
  time_to_gwordnum = root.time_to_gwordnum
  if not time_to_gwordnum[time]?
    return
  gwordidx = time_to_gwordnum[time]
  if gwordidx == root.prevGwordIdx
    return
  root.prevGwordIdx = gwordidx
  console.log gwordidx
  singerReceivesWords(null, null, gwordidx)
  widx = now.gwordidx_to_wordidx[gwordidx]
  singerReceivesHighlightedWord(widx)

now.singerReceivesSongName = (songname) ->
  if $('#songName').text() == songname
    return
  $('#songName').text(songname)

now.singerReceivesSongVideo = (videourl) ->
  if not root.showplayer
    return
  if $(".video video")[0].src == videourl
    return
  $(".video video")[0].src = videourl

root.videoLoaded = () ->
  if not root.showplayer
    return
  videourl = $(".video video")[0].src
  videolength = $(".video video")[0].duration
  if not root.singleplayer
    return
  now.getTimingInfoForSong(videourl, videolength, (data) ->
    #console.log data
    root.time_to_gwordnum = compute_time_word_path(data)
  )

now.singerReceivesSongId = (id) ->
  if not root.showplayer
    return
  now.requestPreview(id, (output) ->
    $(".video video")[0].src = output.response.url[0]
  )

now.ready( ->
  #console.log 'ready to go!'
  now.connectNewSinger()
)

