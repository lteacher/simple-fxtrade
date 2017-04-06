### Ideas

```coffeescript
fx.setAccount 123

# -> GET /accounts/123/instruments
fx.instruments()

# -> GET /accounts
fx.accounts

# -> GET /accounts/123
fx.accounts id: 123

# -> Specials, configuring
fx.setAccountId 123
fx.configure accountId: 123

# -> GET /accounts/123/orders
fx.orders()

# -> POST /accounts/123/orders ?? what alt, see below
fx.orders [id: 2323, id: 5454]

# Change http method?
fx('get').orders()
fx('post').orders [id: 2323, id: 5454] # Since takes coll?

# -> GET /accounts/123/orders/1212121
fx.orders id: 121212

# -> POST /accounts/123/orders/1212121/cancel
fx.orders.cancel id: 1212121
```
