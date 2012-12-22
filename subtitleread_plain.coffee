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
    gwordidx_to_lineidx = []
    gwordidx_to_wordidx = []
    gwordidx = 0
    subtitles = (x.trim() for x in subtitleText.split('\n'))
    subtitles = (x for x in subtitles when x != '')
    for line,lineidx in subtitles
      linelength = line.split(' ').length
      for i in [0..linelength]
        gwordidx_to_lineidx[gwordidx + i] = lineidx
        gwordidx_to_wordidx[gwordidx + i] = i
      gwordidx_at_linestart.push gwordidx
      gwordidx += linelength
    @subtitles = subtitles
    @gwordidx_at_linestart = gwordidx_at_linestart
    @gwordidx_to_lineidx = gwordidx_to_lineidx
    @gwordidx_to_wordidx = gwordidx_to_wordidx
    @numwords = gwordidx

  subtitleAtIndex: (idx) ->
    return @subtitles[idx]

  togwordidx: (idx, lineidx) ->
    return @gwordidx_at_linestart[lineidx] + idx

root.SubtitleRead = SubtitleRead
root.toDeciSeconds = toDeciSeconds
