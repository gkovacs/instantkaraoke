function checkKey(x) {
  if ($('.searchfield').is(':focus')) {
      return;
  }
  var vid = $('video')[0]
  console.log(x.keyCode)
  keypressed = String.fromCharCode(event.keyCode)
  
  if (x.keyCode == 38) { // up arrow
    setCurrentIdx(currentIdx - 1)
    x.preventDefault()
  } else if (x.keyCode == 40) { // down arrow
    setCurrentIdx(currentIdx + 1)
    x.preventDefault()
  }

  if (keypressed.toLowerCase() == activeletter.toLowerCase()) {
    setActiveWordIndex(activeWordIndex + 1)
    return false
  }
  if (x.keyCode == 32 || x.keyCode == 39) { // space or right arrow
    setActiveWordIndex(activeWordIndex + 1)
    x.preventDefault()
    return false
    /*
    if (vid.paused)
      vid.play()
    else
      vid.pause()
    x.preventDefault()
    return false
    */
  } else if (x.keyCode == 37) { // left arrow
    if (x.ctrlKey) {
      prevButtonPressed()
    } else {
      vid.currentTime -= 5
    }
    x.preventDefault()
    return false
  } else if (x.keyCode == 39) { // right arrow
    if (x.ctrlKey) {
      nextButtonPressed()
    } else {
      vid.currentTime += 5
    }
    x.preventDefault()
    return false
  } /*else if (x.keyCode == 38) { // up arrow
    prevButtonPressed()
    x.preventDefault()
  } else if (x.keyCode == 40) { // down arrow
    nextButtonPressed()
    x.preventDefault()
  }*/
  else if (x.keyCode == 82) { // r button
    recomputeAlignment()
  }
}

$(document).keydown(checkKey)

