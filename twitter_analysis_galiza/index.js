var twitterAPI = require('node-twitter-api');
var twitter = new twitterAPI({
    consumerKey: 'rYh1wRySn0W9WqCFex6wwHtSs',
    consumerSecret: 'qpvCHUiLvE3VTrOJk4EA4zQbLeXSUz1hnYSi8jCLf9XfwxZ279',
    callback: 'oob'
});

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
  
  var rl = require('readline').createInterface(process.stdin, process.stdout);
  rl.question("Auth token: ", function(answer) {
    token['token'] = answer.trim();

    rl.question("Auth secret: ", function(answer) {
      token['secret'] = answer.trim();
      console.log(JSON.stringify(token));

      rl.question("Query: ", function(answer) {
        twitter.search(
          {
            'q' : answer.trim(),
            'result_type' : 'recent',
            'count' : 100
          },
          token.token,
          token.secret,
          function (error, data, response) {
           for (var tweet_n in data.statuses) {
             var tweet = data.statuses[tweet_n];
             console.log("Tweet key " + tweet_n + " : ");

             console.log("> " + tweet.user.name + " @ " + tweet.user.location);
             console.log(">>>> geo " + JSON.stringify(tweet.geo));
             console.log(">>>> coo " + JSON.stringify(tweet.coordinates));
           
             console.log("");
           } 
        });
      });
    });
  });
});

