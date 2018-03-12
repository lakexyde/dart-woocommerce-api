import 'package:oauth/oauth.dart';
import 'package:oauth/src/utils.dart';
import 'package:oauth/src/token.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

const Base64Codec _base64 = const Base64Codec();

class WooCommerceAPI{
  String url;
  bool wpApi;
  String wpApiPrefix;
  String version;
  bool isSsl;
  String consumerKey;
  String consumerSecret;
  bool verifySsl;
  String encoding;
  bool queryStringAuth;
  String port;
  int timeout;
  String classVersion;

  WooCommerceAPI(Map<String,dynamic> opt){

    if(opt['url'] == null) throw new FormatException("Url is required");
    if(opt['consumerKey'] == null) throw new FormatException("Consumer Key is required");
    if(opt['consumerSecret'] == null) throw new FormatException("Consumer Secret is required");

    this.classVersion = '1.0.0';
    this.setDefaultOptions(opt);
  }

  String theAPiUrl(){
    if(this.wpApi){
      var t = this.wpApiPrefix + '/';
      return t;
    } else {
      return "wp-json/";
    }
  }

  void setDefaultOptions(Map<String,dynamic> opt){
    this.url = opt['url'];
    this.wpApi = opt['wpApi'] ?? false;
    this.wpApiPrefix = opt['wpApiPrefix'] ?? "json";
    this.version = opt['version'] ?? "v3";
    this.isSsl = (Uri.parse(this.url).scheme == 'https');
    this.consumerKey = opt['consumerKey'];
    this.consumerSecret = opt['consumerSecret'];
    this.verifySsl = (opt['verifySsl'] == false) ? false : true;
    this.encoding = opt['encoding'] ?? 'utf8';
    this.queryStringAuth = opt['queryStringAuth'] ?? false;
    this.port = opt['port'] ?? '';
	  this.timeout = opt['timeout'];
  }

  String normalizeQueryString(String url){
    if(url.indexOf('?') == -1) return url;

    var q = Uri.parse(url).query;
    var query = Uri.splitQueryString(q);
    var params = [];
    var queryString = "";

    query.forEach((key, _){
      params.add(key);
    });
    params.sort();

    for(var i in params){
      if(queryString.length > 0){
        queryString += '&';
      }
      queryString += Uri.encodeComponent(i).replaceAll('%5B', '[')
      .replaceAll('%5D', ']');
      queryString += '=';
      queryString += Uri.encodeComponent(query[i]);
    }

    return url.split('?')[0] + '?' + queryString;
  }

  String composeQueryString(Map data){
    if(data.containsKey('oauth_signature')){
      data['oauth_signature'] = Uri.encodeComponent( data['oauth_signature']);
    }
    var params = [];
    data.forEach((key, value){
      params.add("$key=$value");
    });

    return params.join("&");
  }

  String getUrl(String endpoint){
    int l = this.url.length - 1;
    var url = (this.url[l] == '/') ? this.url : this.url + '/';
    var api = this.theAPiUrl();

    url = url + api + this.version + '/' + endpoint;

    if ('' != this.port) {
      var hostname = Uri.parse(url).host;
      url = url.replaceAll(hostname, hostname + ':' + this.port);
    }

    if (!this.isSsl) {
      return this.normalizeQueryString(url);
    }

    return url;
  }

  Tokens getTokens(){
    Tokens tokens = new Tokens(consumerId: this.consumerKey, consumerKey: this.consumerSecret, userId: this.consumerKey, userKey: this.consumerSecret, type: "HMAC-SHA1");

    return tokens;
  }

  join(){

  }

  String request(String method, String endpoint, Map data, Function callback){
    var url = this.getUrl(endpoint);

    // http.BaseRequest(); ({
    //   "uri": url,
    //   "method": method,
    //   "headers": {
    //     'User-Agent': 'WooCommerce API Flutter/' + this.classVersion,
    //     'Content-Type': 'application/json',
    //     'Accept': 'application/json'
    //   }
    // });

    var tokens = this.getTokens();

    http.Request r = new http.Request(method, Uri.parse(url));
    var nonce = getRandomBytes(8);
    String nonceStr = _base64.encode(nonce);

    var params = generateParameters(r, tokens, nonceStr, new DateTime.now().millisecondsSinceEpoch ~/ 1000);

    var t = composeQueryString(params);

    var requestUrl = url + "?" + t;

    //Extra data for paging
    if(data != null && data.isNotEmpty){
      var q = composeQueryString(data);
      requestUrl += "&"+ q;
      print(requestUrl);
    }

    return requestUrl;
  }

  Future get(String endpoint,{Map data, Function callback}) async{
    var reqUrl = this.request("GET", endpoint, data, callback);

    HttpClient client = new HttpClient();
    client.openUrl("GET", Uri.parse(reqUrl))
    .then((HttpClientRequest request) {
      request.headers.contentType
        = new ContentType("application", "json", charset: "utf-8");
      request.headers.set(HttpHeaders.CACHE_CONTROL,
                    'no-cache');
      return request.close();
    })
    .then((HttpClientResponse response) {
      response.transform(UTF8.decoder).listen((contents) {
         print(contents);
       });
      
    }).catchError((err){
       print(err);
    });
    
  }

}
