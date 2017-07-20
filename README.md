# Simple FxTrade

> _A node js wrapper for the Oanda Rest v20 api to make things really simple._

[![Build Status](https://travis-ci.org/lteacher/simple-fxtrade.svg?branch=master)](https://travis-ci.org/lteacher/simple-fxtrade)
[![Coverage Status](https://coveralls.io/repos/github/lteacher/simple-fxtrade/badge.svg?branch=master)](https://coveralls.io/github/lteacher/simple-fxtrade?branch=master)
[![npm version](https://badge.fury.io/js/simple-fxtrade.svg)](https://badge.fury.io/js/simple-fxtrade)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/lteacher/simple-fxtrade/master/LICENSE.md)

## Overview

This package is a wrapper around the [Oanda Rest-v20 api][oanda-api]. All request parameters, payloads or response structures are documented there so you won't find that information here.

The purpose of this package is to simplify the url constructions and expose the endpoints in a nice way for any Nodejs based projects. The package should also work as described in browsers via `fx` global or by `require` / `import`. 

Here is an example:

```javascript
const fx = require('simple-fxtrade');

// Get accounts for authorized user (using OANDA_API_KEY env var)
const {accounts: [{id}]} = await fx.accounts()

// Set the id context for all future api calls
fx.setAccount(id);

// Get the instruments for the account
const {instruments} = await fx.instruments();
```

## Install

Install via npm with the following
```sh
npm i --save simple-fxtrade
```

## Usage

### Configuration

To change certain aspects of the api wrapper, you can use the `configure` function. For example you may want to set the `apiKey`.

```javascript
// Use configure to change the default values which are shown below
fx.configure({
  apiKey: 'dsadsds',  // Defaults to OANDA_API_KEY environment variable
  live: false,        // Set to true to use the live api instead of practice
  version: 'v3',      // Probably never need to change this
  accountId: '23243', // Set this if you know the accountId up front
  dateTimeFormat: 'RFC3339', // Per oanda documentation
  throwHttpErrors : true // * See notes
});

// You needn't set all values, a more realistic example may be like
fx.configure({ live: true, accountId: '111-002-111-2' });
```

- `apiKey` - Default: env variable `OANDA_API_KEY`. Sets the `Authorization` header key.  Best practice would be to use some config or env management package to set this and never pass the value. But you can if you want.

- `live` - Default: false. This affects the endpoint url. If set to true the host is `fxtrade.oanda.com`, when false its `fxpractice.oanda.com`

- `accountId` - Default: not set. If you know the accountId you could set it here. Most endpoints need the accountId set

- `throwHttpErrors` translates directly to the [`request-promise`][request-promise] package options `simple` and `resolveWithFullResponse`. How this relates is that when true, error http codes will return as a rejection and successful responses only resolve the `body` of the response. If false, all responses resolve and the response has all of the `httpResponse` properties, such as `statusCode`

If you are messing around on a demo account, with the `OANDA_API_KEY` set, then you may never need to use `configure`. Instead you can just use `setAccount`, in fact for most of the endpoints you must set the account before hand. Heres what it might look like if you maybe know the id.

```javascript
// Usually get the accounts and the id, but then set it
// All defaults are already configured to work
fx.setAccount('111-222-333');
```

### Api Endpoints
The following api endpoints are implemented. In most cases the request parameters are the same and response is a direct pass through. Each heading matches with the official documentation headings.

_**Note:** ALL api examples assume that you have `setAccount(id)` as there are only 3 or so routes that dont need it set_

#### Account
Only the `accounts()` function can be used without setting the `accountId`


```javascript
// GET /accounts
const {accounts} = await fx.accounts();

// GET /accounts/:id
const {account} = await fx.accounts({ id });

// PATCH /accounts/:id/configuration
await fx('patch').accounts({ id, alias: 'Default' });

// GET /accounts/:accountId/summary - Notice the accountId is used from the config
const {account} = await fx.summary();

// GET /accounts/:accountId/instruments
const {instruments} = await fx.instruments();

// GET /accounts/:id/changes
const {changes} = await fx.changes({ sinceTransactionID: 20 });
```

#### Instrument
The only relevant function here is `candles()` it doesn't require the `accountId`.

```javascript
// GET /instrument/:id/candles
const {candles, instrument} = await fx.candles({ id: 'AUD_USD' });
```

#### Order
All of the functions for orders require the `accountId` to be set.

```javascript
// GET /accounts/:accountId/orders
const {orders} = await fx.orders();

// GET /accounts/:accountId/orders/:id
const {orders} = await fx.orders({ id });

// POST /accounts/:accountId/orders
await fx.orders.create({
  order: {
    units: 1,
    instrument: 'AUD_USD',,
    timeInForce: 'FOK'
    type: 'MARKET',
    positionFill: 'DEFAULT',
    tradeId: 6368
  }
});

// PUT /accounts/:accountId/orders/:id
await fx.orders.replace({ id, order: ... });  // See oanda docs for payload examples

// PUT /accounts/:accountId/orders/:id/cancel
await fx.orders.cancel({ id });

// PUT /accounts/:accountId/orders/:id/clientExtensions
await fx.orders.clientExtensions({ id, clientExtensions });
```

#### Trade
All of the functions require the `accountId` to be set. See oanda docs for payload examples. They are just provided as an object parameter.

```javascript
// GET /accounts/:accountId/trades
const {trades} = await fx.trades({ count: 10, instrument: 'AUD_USD' });

// GET /accounts/:accountId/trades/:id
const {trade} = await fx.trades({ id });

// PUT /accounts/:accountId/trades/:id/close
await fx.trades.close({ id })

// PUT /accounts/:accountId/trades/:id/clientExtensions
await fx.trades.clientExtensions({ id, clientExtensions });

// PUT /accounts/:accountId/trades/:id/orders
await fx.trades.orders({ id, takeProfit }); // etc...
```

#### Position
Again all functions need the `accountId` to have been set before hand.

```javascript
// GET /accounts/:accountId/positions
const {positions} = await fx.positions();

// GET /accounts/:accountId/positions/:id <- instrument id
const {position} = await fx.positions({ id });

// PUT /accounts/:accountId/positions/:id/close
await fx.positions.close({ id });
```

#### Transaction
Set the `accountId` first

```javascript
// GET /accounts/:accountId/transactions
const {transactions} = await fx.transactions()

// GET /accounts/:accountId/transactions/:id
const {transactions} = await fx.transactions({ id })
```

#### Pricing

```javascript
// GET /accounts/:accountId/pricing?instruments=AUD_USD
const {prices} = await fx.pricing({ instruments: 'AUD_USD' })
```

### Stream Endpoints
Good news, both the `pricing` and the `transactions` streams are implemented. Here is an example of using the pricing stream.

```javascript
// GET /accounts/:accountId/pricing/stream?instruments=AUD_USD
const stream = fx.pricing.stream({ instruments: 'AUD_USD' });

// Handle some data
stream.on('data', data => {
  console.log(data.type); // PRICE or HEARTBEAT
});

// Sometime later when done with the stream
stream.disconnect();
```


[oanda-api]:(http://developer.oanda.com/rest-live-v20/introduction/)
[request-promise]:(https://www.npmjs.com/package/request-promise)
