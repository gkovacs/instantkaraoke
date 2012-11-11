$(".searchform").submit(function(event) {
  event.preventDefault();
  now.searchTrack(this.query.value, function(output) {
      $.each(output.response.searchResults[0].searchResult, function(i, item) {
          console.log(item.score[0] + " " + item.track[0].title);
          // console.log(item);
      }) 
      console.log(output.response.searchResults[0].searchResult[0].track[0]);
      console.log(output.response.searchResults[0].searchResult[0].track[0].isrc[0]);
    $("#track").html(output.response.searchResults[0].searchResult[0].track[0].artist[0].name + " - " + output.response.searchResults[0].searchResult[0].track[0].title);
    now.requestTrack(output.response.searchResults[0].searchResult[0].track[0].id, function(output) {
        console.log(output.response.url[0]);
        $(".video video")[0].src = output.response.url[0];
    })
    now.requestSubtitles(output.response.searchResults[0].searchResult[0].track[0].isrc[0], function(output) {
        // console.log(output);
    })
  })
  $(".searchfield").blur();
});
