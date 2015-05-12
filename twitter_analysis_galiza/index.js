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
    token = {
      'token' : requestToken,
      'secret' : requestTokenSecret
    };
    //store token and tokenSecret somewhere, you'll need them later; redirect user 
  }
  console.log(JSON.stringify(token));
});


twitter.search("tweets", 
  {
    'q' : "galiciabilingue"
  },
  token.token,
  token.secret,
  function (error, data, response) {
    console.log("Error :" + JSON.stringify(error));
    console.log("Data : " + JSON.stringify(data));
  }
);

