# dart-woocommerce-api

Still a work in progress.

## How to install
- include the dart oauth library in your pubspec.yaml
```oauth: ^0.4.0```
- Copy woocommerce.dart into a folder
- import like so:
```import './woocommerce.dart';```

## Usage
- Create a instance of the WooCommerceAPI class and include your parameters;
```
Map<String,dynamic> params = {
  "url": 'http://example.com',
  "consumerKey": "ck_xxxxxxxxxxxxxxxxxxx",
  "consumerSecret": "cs_xxxxxxxxxxxxxxxxxx",
  "wpAPI": true,
  "version": 'wc/v2'
};

WooCommerceAPI api = new WooCommerceAPI(params);
```
- Get products
```
api.get("products").then((data){
  print(data);
});
```


## Todo
- Include POST, PUT, DELETE Request handling
