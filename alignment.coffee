root = exports ? this

compute_time_word_path = (time_to_gwordnum_count) ->
  DP = [] # scores at time -> gwordnum
  backptr_wordtrans = [] # 1 if we got there by word transition, 0 otherwise
  for time,gwordnum_count of time_to_gwordnum_count
    DP[time] = []
    backptr_wordtrans[time] = []
    for gwordnum in [0..Math.min(time, gwordnum_count.length-1)]
      DP[time].push(0)
      backptr_wordtrans[time].push(0)
  for gwordnum_count,time in time_to_gwordnum_count
    if time == 0
      DP[0][0] = time_to_gwordnum_count[0][0]
      continue
    for gwordnum in [0..Math.min(time, gwordnum_count.length-1)]
      wordtransition_score = -1
      if gwordnum > 0
        wordtransition_score = DP[time-1][gwordnum-1] + time_to_gwordnum_count[time][gwordnum]
      wordstay_score = -1
      if DP[time-1]? and DP[time-1][gwordnum]?
        wordstay_score = DP[time-1][gwordnum] + time_to_gwordnum_count[time][gwordnum]
      if wordtransition_score > wordstay_score
        backptr_wordtrans[time][gwordnum] = 1
        DP[time][gwordnum] = wordtransition_score
      else
        DP[time][gwordnum] = wordstay_score
  console.log DP
  console.log backptr_wordtrans
  time_to_word = []
  last_row = backptr_wordtrans[backptr_wordtrans.length-1]
  word_idx = last_row.length - 1
  for i in [backptr_wordtrans.length-1..0]
    is_wordtrans = backptr_wordtrans[i][word_idx]
    time_to_word.push(word_idx)
    if is_wordtrans
      word_idx -= 1
  time_to_word.reverse()
  return time_to_word
  #console.log time_to_word

root.compute_time_word_path = compute_time_word_path


#console.log compute_time_word_path [[1, 0, 0], [0, 1, 0], [0, 1, 0], [0, 0, 1], [0, 0, 1] ]
