root = exports ? this

root.videoLoaded = ->
  videoWidth = $('video')[0].videoWidth
  $('video').css('height', '0px')
  $('video').css('width', '300px')

root.wordSet = []
root.wordHTML = []

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

root.currentIdx = 0

setCurrentIdx = root.setCurrentIdx = (idx) ->
  root.currentIdx = Math.max(idx, 0)
  now.getSubAtIndex(idx, (subs) ->
    subsChanged(subs)
  )

root.setWordColor = setWordColor = (i, color) ->
  root.wordHTML[i] = '<span style="color: ' + color + '"> ' + root.wordSet[i] + ' </span>'

getCurrentTime = () ->
  return $('video')[0].currentTime

root.setActiveWordIndex = setActiveWordIndex = (idxnum) ->
  now.sendWordHighlightedToServer(idxnum-1, getCurrentTime())
  root.activeWordIndex = idxnum
  word = root.wordSet[idxnum]
  if idxnum == root.wordSet.length and idxnum != 0
    setWordColor(idxnum-1, 'black')
    $('#lyricsDisplay').html(root.wordHTML.join(''))
    return
  if not word?
    return
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
  if root.currentsubs == subs or not subs?
    return
  root.currentsubs = subs
  root.wordSet = (x.toUpperCase() for x in subs.split(' '))
  now.sendWordsToServer(root.wordSet)
  root.wordHTML = []
  for word,idx in root.wordSet
    root.wordHTML.push '<span style="color: grey"> ' + escapeHtmlQuotes(word) + ' </span> '
  setActiveWordIndex(0)

root.onTimeChanged = (vid) ->
  #now.getSubAtTime(vid.currentTime, (subs) ->
  #  subsChanged(subs)
  #)

now.ready(->
  setCurrentIdx(0)
  #now.requestSubtitles('USUM70984099', (data) ->
  #  console.log ''
  #)
)
