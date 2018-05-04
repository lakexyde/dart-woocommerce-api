import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

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

  String theAPiUrl(){
    if(this.wpApi){
      var t = this.wpApiPrefix + '/';
      return t;
    } else {
      return "wp-json/";
    }
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
      queryString += Uri.encodeComponent(i).replaceAll('[','%5B')
      .replaceAll('%5D', ']');
      queryString += '=';
      queryString += Uri.encodeComponent(query[i]);
    }

    return url.split('?')[0] + '?' + queryString;
  }

  String composeQueryString(Map data){
    var params = [];
    data.forEach((key, value){
      params.add("$key=$value");
    });
    return params.join("&");
    // .replaceAll('[','%5B').replaceAll(']','%5D');
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

  Uri composeUrl(String endpoint, Map data){
    String _scheme = Uri.parse(this.url).scheme;
    String _host = Uri.parse(this.url).host;
    int _port = Uri.parse(this.url).port ?? 8080;
    String _queryString = composeQueryString(data);
    String _path = this.theAPiUrl() + this.version + '/' + endpoint;
  
    Uri _uri = new Uri(
      scheme: _scheme,
      host: _host,
      port: _port,
      path: _path,
      query: _queryString
    );

    return _uri;
  }

  String authHeader(){
    var basicAuthHeader = base64.encode(utf8.encode("${this.consumerKey}:${this.consumerSecret}"));
    return basicAuthHeader;
  }

  Future request(String method, String endpoint, Map data) async{
    var url = this.getUrl(endpoint);

    var t = composeQueryString(data);

    var _rq = url + "?" + t;

    var requestUrl = Uri.encodeFull(_rq);
    print(requestUrl);

    var basicAuthHeader = base64.encode(utf8.encode("${this.consumerKey}:${this.consumerSecret}"));

    var httpClient = new HttpClient();
    var request = await httpClient.openUrl(method, Uri.parse(requestUrl));
    request.headers.contentType = new ContentType("application", "json", charset: "utf-8");
    request.headers.set(HttpHeaders.CACHE_CONTROL, 'no-cache');
    request.headers.set(HttpHeaders.AUTHORIZATION, 'Basic ' + basicAuthHeader);
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    var dataResponse = await json.decode(responseBody);
    return dataResponse;
  }


  Future get(String endpoint, Map data){
    return this.request("GET", endpoint, data);
  }

  Future post(String endpoint, Map data) async{
    String _authHeader = authHeader();
    var url = this.getUrl(endpoint);

    var client = new http.Client();
    var request = new http.Request('POST', Uri.parse(url));
    request.headers[HttpHeaders.CONTENT_TYPE] = 'application/json; charset=utf-8';
    request.headers[HttpHeaders.AUTHORIZATION] = "Basic $_authHeader";
    request.headers[HttpHeaders.CACHE_CONTROL] = "no-cache";
    request.body = json.encode(data);
    var response = await client.send(request).then((res) => res.stream.bytesToString());
    var dataResponse = await json.decode(response);
    return dataResponse;
  }

  Future put(String endpoint, Map data) async{
    String _authHeader = authHeader();
    var url = this.getUrl(endpoint);

    var client = new http.Client();
    var request = new http.Request('PUT', Uri.parse(url));
    request.headers[HttpHeaders.CONTENT_TYPE] = 'application/json; charset=utf-8';
    request.headers[HttpHeaders.AUTHORIZATION] = "Basic $_authHeader";
    request.headers[HttpHeaders.CACHE_CONTROL] = "no-cache";
    request.body = json.encode(data);
    var response = await client.send(request).then((res) => res.stream.bytesToString());
    var dataResponse = await json.decode(response);
    print(dataResponse);
    return dataResponse;

  }

  Future delete(String endpoint,{Map data}){
    return this.request("DELETE", endpoint, data);
  }
}
