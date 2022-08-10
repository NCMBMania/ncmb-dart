import 'request.dart';

class NCMBScript {
  final String scriptName;
  Map<String, String> _headers = {};
  Map<String, Object> _body = {};
  Map<String, String> _query = {};

  NCMBScript(this.scriptName);

  NCMBScript header(String name, String value) {
    _headers[name] = value;
    return this;
  }

  NCMBScript body(String name, Object value) {
    _body[name] = value;
    return this;
  }

  NCMBScript query(String name, Object value) {
    _query[name] = value.toString();
    return this;
  }

  Future<Object> get() {
    NCMBRequest r = new NCMBRequest();
    return r.exec('GET', scriptName,
        queries: _query, additionalHeaders: _headers, isScript: true);
  }

  Future<Object> post() {
    NCMBRequest r = new NCMBRequest();
    return r.exec('POST', scriptName,
        queries: _query,
        additionalHeaders: _headers,
        fields: _body,
        isScript: true);
  }

  Future<Object> put() {
    NCMBRequest r = new NCMBRequest();
    return r.exec('PUT', scriptName,
        queries: _query,
        additionalHeaders: _headers,
        fields: _body,
        isScript: true);
  }

  Future<Object> delete() {
    NCMBRequest r = new NCMBRequest();
    return r.exec('DELETE', scriptName,
        queries: _query,
        additionalHeaders: _headers,
        fields: _body,
        isScript: true);
  }
}
