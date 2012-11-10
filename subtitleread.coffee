root = exports ? this
print = console.log

toDeciSeconds = (time) ->
  time = time.split(',').join('.')
  [hour,min,sec] = time.split(':')
  hour = parseFloat(hour)
  min = parseFloat(min)
  sec = parseFloat(sec)
  return Math.round((hour*3600 + min*60 + sec)*10)

class SubtitleRead
  constructor: (subtitleText) ->
    @subtitleText = subtitleText
    lastStartTime = 0
    timeToSubtitle = {}
    timesAndSubtitles = [] # start,end,subtitle
    awaitingTime = true
    startTime = 0.0
    endTime = 0.0
    lineContents = ''
    for line in subtitleText.split('\n')
      line = line.trim()
      if line == ''
        if lineContents != ''
          timesAndSubtitles.push([startTime,endTime,lineContents])
        awaitingTime = true
        lineContents = ''
      else if awaitingTime
        if line.indexOf(' --> ') != -1
          awaitingTime = false
          [startTime, endTime] = line.split(' --> ')
          startTime = toDeciSeconds(startTime)
          endTime = toDeciSeconds(endTime)
          awaitingTime = false
      else
        lineContents = (lineContents + ' ' + line).trim()
    if lineContents != ''
      timesAndSubtitles.push([startTime,endTime,lineContents])
    
    for triplet in timesAndSubtitles
      [startTime,endTime,lineContents] = triplet
      if startTime > lastStartTime
        lastStartTime = startTime
      while startTime < endTime + 50
        timeToSubtitle[startTime] = lineContents
        ++startTime
    @timeToSubtitle = timeToSubtitle
    @timesAndSubtitles = timesAndSubtitles
    @lastStartTime = lastStartTime

  getSubtitleIndexFromTime: (deciSec) ->
    lidx = 0
    ridx = @timesAndSubtitles.length-1
    while lidx < ridx+1
      midx = Math.floor((lidx + ridx)/2)
      ctime = @timesAndSubtitles[midx][0]
      if ctime > deciSec
        ridx = midx - 1
      else
        lidx = midx + 1
    if ridx < 0
      ridx = 0
    return ridx

  getTimesAndSubtitles: () ->
    return @timesAndSubtitles

  subtitleAtTime: (sec) ->
    deciSec = Math.round(sec * 10)
    retv = this.timeToSubtitle[deciSec]
    if retv
      retv
    else
      ''

  subtitleAtTimeAsync: (deciSec, callback) ->
    callback(@subtitleAtTime(deciSec))

root.SubtitleRead = SubtitleRead
root.toDeciSeconds = toDeciSeconds
