root = exports ? this

root.videoLoaded = ->
  videoWidth = $('video')[0].videoWidth
  $('video').css('left', '50%')
  $('video').css('margin-left', -Math.round(videoWidth/2))

root.wordSet = []
root.wordHTML = []

root.singing = false

replaceAll = (str, from, to) ->
  return str.split(from).join(to)

escapeHtmlQuotes = (str) ->
  replacements = [['&', '&amp;'], ['>', '&gt;'], ['<', '&lt;'], ['"', '&quot;'], ["'", '&#8217;']]
  for [from,to] in replacements
    str = replaceAll(str, from, to)
  return str

root.activeWordIndex = 0
root.activeletter = ''
root.currentsubs = ''

root.setWordColor = setWordColor = (i, color) ->
  root.wordHTML[i] = '<span style="color: ' + color + '"> ' + root.wordSet[i] + ' </span>'

root.setActiveWordIndex = setActiveWordIndex = (idxnum) ->
  root.activeWordIndex = idxnum
  word = root.wordSet[idxnum]
  if idxnum == root.wordSet.length and idxnum != 0
    now.sendWordsToServer(root.wordSet)
    setWordColor(idxnum-1, 'black')
    $('#lyricsDisplay').html(root.wordHTML.join(''))
    return
  if not word?
    return
  now.sendWordsToServer(root.wordSet[0...idxnum])
  root.activeletter = word[0..0]
  remainder = word[1..]
  activeletterspan = '<span style="color: red">' + escapeHtmlQuotes(root.activeletter) + '</span>'
  remainderspan = '<span style="color: grey">' + escapeHtmlQuotes(remainder) + '</span>'
  newhtml = activeletterspan + remainderspan
  for i in [0...idxnum]
    setWordColor(i, 'black')
  root.wordHTML[idxnum] = newhtml
  for i in [idxnum+1..root.wordHTML]
    setWordColor(i, 'grey')
  $('#lyricsDisplay').html(root.wordHTML.join(''))

subsChanged = (subs) ->
  if root.currentsubs == subs
    return
  now.sendWordsToServer([])
  root.currentsubs = subs
  root.wordSet = (x.toUpperCase() for x in subs.split(' '))
  root.wordHTML = []
  for word,idx in root.wordSet
    root.wordHTML.push '<span style="color: grey"> ' + escapeHtmlQuotes(word) + ' </span> '
  setActiveWordIndex(0)

root.onTimeChanged = (vid) ->
  now.getSubAtTime(vid.currentTime, (subs) ->
    subsChanged(subs)
  )
