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
    gwordidx_at_linestart = []
    gwordidx = 0
    for line in subtitleText.split('\n')
      line = line.trim()
      if line == ''
        continue
      subtitles.push line
      gwordidx_at_linestart.push gwordidx
      gwordidx += line.split(' ').length
    @subtitles = subtitles
    @gwordidx_at_linestart = gwordidx_at_linestart
    @numwords = gwordidx

  subtitleAtIndex: (idx) ->
    return @subtitles[idx]

  togwordidx: (idx, lineidx) ->
    return @gwordidx_at_linestart[lineidx] + idx

root.SubtitleRead = SubtitleRead
root.toDeciSeconds = toDeciSeconds
