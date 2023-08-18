
import 'package:http/http.dart' as http;

http.Request _cloneNormalRequest(http.Request original) {
  var request = http.Request(original.method, original.url);
  request.followRedirects = original.followRedirects;
  request.headers.addAll(original.headers);
  request.maxRedirects = original.maxRedirects;
  request.persistentConnection = original.persistentConnection;
  request.body = original.body;

  return request;
}

http.BaseRequest cloneRequest(http.BaseRequest original) {
  if (original is http.Request) {
    return _cloneNormalRequest(original);
  } else {
    throw UnimplementedError(
        'Cannot handle yet requests of type ${original.runtimeType}');
  }
}
