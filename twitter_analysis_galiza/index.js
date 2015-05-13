var twitterAPI = require('node-twitter-api');
var twitter = new twitterAPI({
    consumerKey: 'rYh1wRySn0W9WqCFex6wwHtSs',
    consumerSecret: 'qpvCHUiLvE3VTrOJk4EA4zQbLeXSUz1hnYSi8jCLf9XfwxZ279',
    callback: 'oob'
});
var rl = require('readline').createInterface(process.stdin, process.stdout);

var token = {};

twitter.getRequestToken(function(error, requestToken, requestTokenSecret, results){
  if (error) {
    console.log("Error getting OAuth request token : " + JSON.stringify(error));
  } else {
    token['request'] = {
      'token' : requestToken,
      'secret' : requestTokenSecret
    };
  }
  
  rl.question("Auth token: ", function(answer) {
    token['token'] = answer.trim();

    rl.question("Auth secret: ", function(answer) {
      token['secret'] = answer.trim();
      console.log(JSON.stringify(token));

      rl.question("Query: ", function(answer) {
        var page = -1;
        var results = [];

        cursorLoop(page, answer.trim(), results);
      });
    });
  });
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

    console.log(data.users.length);
    console.log(page);

    results.push(data);

    for (var n in data.users) {
      var user = data.users[n];
      console.log("Key " + n + " : ");
      console.log("> " + user.screen_name + " @ " + user.location + "/" + user.profile_location + "(" + user.lang + ")");
      console.log(">>>> geo " + JSON.stringify(user.geo_enabled));
      console.log(">>>> lang " + JSON.stringify(user.lang));

      console.log("");
    }
    if (data.next_cursor == 0) {
      return;
    }
    cursorLoop(data.next_cursor, q, results);
  });
}

