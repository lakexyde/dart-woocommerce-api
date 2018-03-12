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
  "url": 'http://buyryte.com',
  "consumerKey": "ck_77e35e94ad15a7e67056c0d6e840f95548d2946c",
  "consumerSecret": "cs_7faa7dcf9fa507e94db6064ccb7704b7a578dc9d",
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
