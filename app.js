request = require('request');

request("https://api.quadrigacx.com/v2/ticker?book=btc_cad", function(error, response, body) {
  console.log(body);
});
