request = require('request')
crypto = require('crypto-js')
config = require('./config.json')
console.log(config)

nonce = Date.now().toString()
signature = crypto.HmacSHA256(nonce + config.client_id + config.key, config.secret).toString()
keep_going = true

request('http://api.fixer.io/latest?base=CAD', (error, response, body) ->
  data = JSON.parse(body)
  cadusd = data.rates.USD

  do run = ->
    if keep_going 
      setTimeout(run, 10000)

    request('https://api.bitfinex.com/v1/pubticker/btcusd', (error, response, body) ->
      data = JSON.parse(body)
      finex_bid = (data.bid / cadusd).toFixed(2)
      console.log('Finex bid price: ' + finex_bid)

      request('https://api.quadrigacx.com/v2/order_book', (error, response, body) ->
        data = JSON.parse(body)
        quadriga_ask = data.asks[0][0]
        amount = data.asks[0][1]
        console.log('Quadriga ask price: ' + quadriga_ask)

        diff = (finex_bid - quadriga_ask).toFixed(2)
        percent = ((diff / finex_bid) * 100).toFixed(2)
        console.log('Percent difference: ' + percent + '%\n')

        if percent > 1.5
          params = 
            form:
              key: config.key
              nonce: config.nonce
              signature: config.signature
              amount: Math.min(0.01, amount)
              price: quadriga_ask

          request.post("https://api.quadrigacx.com/v2/buy", params, (error, response, body) ->
            data = JSON.parse(body)
            console.log(data)
            keep_going = false
          )
      )
    )
)
