part of '../ncmb.dart';

class NCMBRequest {
  NCMB _ncmb;
  NCMBRequest(NCMB ncmb) {
    _ncmb = ncmb;
  }
  
  Future<List> get(String name, Map queries) async {
    var res = await exec('GET', name, queries: queries);
    return res['results'] as List;
  }
  
  Future<Map> post(String name, Map fields) async {
    return exec('POST', name, fields: fields);
  }
  
  Future<Map> put(String name, String objectId, Map fields) async {
    return exec('PUT', name, fields: fields, objectId: objectId);
  }
  
  Future<Map> delete(String name, String objectId) async {
    return exec('DELETE', name, objectId: objectId);
  }
  
  Future<Map> exec(String method, String name, {fields = const {}, objectId = '', queries = const {}, path = ''}) async {
    Signature s = new Signature(_ncmb);
    DateTime time = DateTime.now();
    final newFields = Map.from(fields)
      ..removeWhere((k, v) => (k == 'objectId' || k == 'createDate' || k == 'updateDate'));
    String signature = s.generate(method, name, time, objectId: objectId, queries: queries, definePath: path);
    String url = s.url(name, objectId: objectId, queries: queries, definePath: path);
    Map<String, String> headers = {
      "X-NCMB-Application-Key": _ncmb.applicationKey,
      "X-NCMB-Timestamp": time.toIso8601String(),
      "X-NCMB-Signature": signature,
      "Content-Type": "application/json"
    };
    if (_ncmb.sessionToken != null) {
      headers['X-NCMB-Apps-Session-Token'] = _ncmb.sessionToken;
    }
    var response = await req(url, method, newFields, headers);
    if (response.statusCode == 201 || response.statusCode == 200) {
      if (method == 'DELETE') return {};
      return json.decode(response.body);
    } else {
      print(response.body);
      throw Exception(response.body);
    }
  }
  
  String jsonEncode(Map fields) {
    fields.forEach((k, v) {
      if (v is DateTime) {
        var format = new DateFormat("yyyy-MM-ddTHH:mm:ss.S'Z'");
        fields[k] = {
          '__type': 'Date', 'iso': format.format(v)
        };
      }
    });
    print(fields);
    return json.encode(fields);
  }
  
  Future<http.Response> req(String url, String method, Map fields, Map headers) async {
    http.Response response;
    switch (method) {
      case 'GET': {
        response = await http.get(url,
          headers: headers
        );
      }
      break;
      
      case 'POST': {
        response = await http.post(url,
          body: jsonEncode(fields),
          headers: headers
        );
      }
      break;
      
      case 'PUT': {
        response = await http.put(url,
          body: jsonEncode(fields),
          headers: headers
        );
      }
      break;

      case 'DELETE': {
        response = await http.delete(url,
          headers: headers
        );
      }
      break;
    }
    return response;
  }
}