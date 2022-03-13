
var FeedParser = require('feedparser');
var request = require('request');

function main(args) {

      return new Promise(function(resolve, reject) {

            var fp = new FeedParser();

            request.get(args.url).pipe(fp);

            var items = [];
            var meta;

            fp.on('readable', function() {
                  var stream = this;
                  var item;

                  while(item = stream.read()) {
                        if(!meta) meta = item.meta;
                        delete item.meta;
                        items.push(item);
                  }
            });

            fp.on('end', function() {
                  resolve({items:items, meta:meta});
            });

      });

}

exports.main = main;
