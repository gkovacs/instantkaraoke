root = exports ? this

root.videoLoaded = ->
  videoWidth = $('video')[0].videoWidth
  $('video').css('left', '50%')
  $('video').css('margin-left', -Math.round(videoWidth/2))

root.wordSet = []
root.wordHTML = []

replaceAll = (str, from, to) ->
  return str.split(from).join(to)

escapeHtmlQuotes = (str) ->
  replacements = [['&', '&amp;'], ['>', '&gt;'], ['<', '&lt;'], ['"', '&quot;'], ["'", '&#8217;']]
  for [from,to] in replacements
    str = replaceAll(str, from, to)
  return str

subsChanged = (subs) ->
  root.wordSet = subs.split(' ')
  root.wordHTML = []
  for word,idx in root.wordSet
    root.wordHTML.push '<span style="color: grey"> ' + escapeHtmlQuotes(word) + ' </span> '
  #$(root.wordHTML[0])
  $('#lyricsDisplay').html(root.wordHTML.join(''))

root.onTimeChanged = (vid) ->
  now.getSubAtTime(vid.currentTime, (subs) ->
    subsChanged(subs)
  )

