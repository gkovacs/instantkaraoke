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
  if params['singleplayer']?
    root.singleplayer = true
    root.showplayer = true
)

root.words = []

now.singerReceivesVideoControl = (command) ->
  if not root.showplayer
    return
  if command == 'start'
    $('video')[0].play()
  else if command == 'pause'
    $('video')[0].pause()

now.singerReceivesHighlightedWord = (idx) ->
  $(".lyric").css('color', 'black')
  for i in [idx+1...root.words.length]
    $('#ws' + i).css('color', 'grey')
  $('#ws' + (idx-1)).animate({
    'top': '30px'
  }, 100)
  $(".lyric").css('font-size', '20px')
  $('#ws' + idx).css('color', 'red')
  #$('#ws' + idx).css('top', '30px')
  #$('#ws' + idx).css('font-size', '40px')
  $('#ws' + idx).animate({
    'top': '0px'
  }, 100)

now.singerReceivesWords = (words) ->
  root.words = words
  $('#lyricsDisplay').html('')
  for word,i in words
    $('#lyricsDisplay').append("<span style='position: relative; top: 30px; margin-right: 8px; color: grey; font-size: 20px' id='ws#{i}' class='lyric'> " + word + " </span>")
    #fixElementPosition(i)
  #$('#ws0').css('color', 'grey')

now.singerReceivesSongName = (songname) ->
  $('#songName').text(songname)

now.singerReceivesSongVideo = (videourl) ->
  if not root.showplayer
    return
  $(".video video")[0].src = videourl

root.videoLoaded = () ->
  if not root.showplayer
    return
  videourl = $(".video video")[0].src
  videolength = $(".video video")[0].duration
  


now.singerReceivesSongId = (id) ->
  if not root.showplayer
    return
  now.requestPreview(id, (output) ->
    $(".video video")[0].src = output.response.url[0]
  )
