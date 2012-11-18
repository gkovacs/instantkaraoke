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
    subtitles = []
    for line in subtitleText.split('\n')
      line = line.trim()
      if line == ''
        continue
      subtitles.push line
    @subtitles = subtitles

  subtitleAtIndex: (idx) ->
    return @subtitles[idx]

root.SubtitleRead = SubtitleRead
root.toDeciSeconds = toDeciSeconds
