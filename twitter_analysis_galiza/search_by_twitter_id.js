var twitterAPI = require('node-twitter-api');
var twitter = new twitterAPI({
    consumerKey: 'rYh1wRySn0W9WqCFex6wwHtSs',
    consumerSecret: 'qpvCHUiLvE3VTrOJk4EA4zQbLeXSUz1hnYSi8jCLf9XfwxZ279',
    callback: 'oob'
});

var token = {};

if (process.argv[2] == null || process.argv[3] == null || process.argv[4] == null) {
  console.log("Error: not enough arguments: node " + process.argv[1] + " <token> <secret> <query>");
  return;
}

twitter.getRequestToken(function(error, requestToken, requestTokenSecret, results){
  if (error) {
    console.log("Error getting OAuth request token : " + JSON.stringify(error));
  } else {
    token['request'] = {
      'token' : requestToken,
      'secret' : requestTokenSecret
    };
  }
  
  token['token'] = process.argv[2].trim();
  token['secret'] = process.argv[3].trim();
  console.log(JSON.stringify(token));

  var page = -1;
  var results = [];

  cursorLoop(page, process.argv[4].trim(), results);
});


function cursorLoop (page, q, results) {
  twitter.followers('list',
  {
    'user_id' : q,
    'result_type' : 'recent',
    'count' : 200,
    'cursor' : page
  },
  token.token,
  token.secret,
  function (error, data, response) {
    if (error) {
      console.log(error);
    }

    for (var n in data.users) {
      results.push(data.users[n]);
    }

    if (data.next_cursor == 0 || data.next_cursor == null) {
      console.log(JSON.stringify(results, null, 2));
      return;
    }
    
    setTimeout(cursorLoop, 10000, data.next_cursor, q, results);
  });
}

