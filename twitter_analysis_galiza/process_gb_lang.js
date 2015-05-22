var data = JSON.parse(require('fs').readFileSync('results_gb_search.json', 'utf8'));

var wordCount = {};

for (var lang in data) {
  for (var n in data[lang]) {
    var words = data[lang][n].text
      .replace(/[.,?!;()"'-]/g, " ")
      .replace(/http:/g, " ")
      .replace(/\s+/g, " ")
      .toLowerCase()
      .split(" ");

    words.forEach(function (word) {
      if (!(wordCount.hasOwnProperty(word))) {
        wordCount[word] = 0;
      }

      wordCount[word]++;
    });
  }
}

var sortable = [];
for (var n in wordCount) {
      sortable.push([n, wordCount[n]]);
}

sortable.sort(function(a, b) {return a[1] - b[1]})

sortable.forEach(function (word) {
  console.log(word[0] + " " + word[1]);
});
