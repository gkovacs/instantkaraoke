fs = require 'fs'
$ = require 'jQuery'

client = require './client'

toSeconds = (time) ->
  time = time.split(',').join('.')
  [hour,min,sec] = time.split(':')
  hour = parseFloat(hour)
  min = parseFloat(min)
  sec = parseFloat(sec)
  return hour*3600 + min*60 + sec

main = ->
  xmltext = fs.readFileSync('alltherightmoves.xml', 'utf8')
  for x in $(xmltext).find('line')
    if $(x).text() == ''
      continue
    starttime = '00:' + $(x).attr('lrc_timestamp').replace('[', '').replace(']', '')
    starttimesecs = toSeconds(starttime)
    endtimesecs = parseFloat($(x).attr('milliseconds')) / 1000.0
    [hour,min,sec,millisec] = client.toHourMinSecMillisec(endtimesecs)
    endtime = hour + ':' + min + ':' + sec + '.' + millisec
    console.log starttime + ' --> ' + endtime
    console.log $(x).text()
    console.log ''
  #subtext = fs.readFileSync('shaolin.srt', 'utf8')

main() if require.main is module
