part of ncmb;

class Signature {
  NCMB? _ncmb;
  final String _fqdn = 'mbaas.api.nifcloud.com';
  final String _signatureMethod = 'HmacSHA256';
  final String _signatureVersion = '2';
  final String _version = '2013-09-01';
  Map baseInfo = {
    "SignatureVersion": "",
    "SignatureMethod": "",
    "X-NCMB-Application-Key": "",
    "X-NCMB-Timestamp": ""
  };
  
  Signature(NCMB ncmb) {
    _ncmb = ncmb;
    baseInfo['SignatureVersion'] = _signatureVersion;
    baseInfo['SignatureMethod'] = _signatureMethod;
    baseInfo['X-NCMB-Application-Key'] = ncmb.applicationKey;
  }
  
  String path(className, {objectId = '', definePath = ''}) {
    String path = "/$_version";
    if (definePath != '') {
      return "$path/$definePath";
    }
    if (['users', 'push', 'roles', 'files', 'installations'].indexOf(className) > -1) {
      path = "$path/$className";
    } else {
      path = "$path/classes/$className";
    }
    if (objectId != '')
      path = "$path/$objectId";
    return path;
  }
  
  String url(className, {objectId = '', queries = const {}, definePath = ''}) {
    List queryList = [];
    queries.forEach((key, value) {
      if (value is Map || value is List) {
        value = jsonEncode(value);
      }
      if (value is int) {
        value = value.toString();
      }
      queryList.add("$key=${Uri.encodeQueryComponent(value)}");
    });
    String queryString = queryList.length == 0 ? '' : "?${queryList.join('&')}";
    return "https://$_fqdn${path(className, objectId: objectId, definePath: definePath)}$queryString";
  }
  
  String generate(String method, String className, DateTime time, {objectId = '', queries = const {}, definePath = ''}) {
    baseInfo['X-NCMB-Timestamp'] = time.toIso8601String();
    List sigList = [];
    queries.forEach((key, value) {
      if (value is Map || value is List) {
        value = jsonEncode(value);
      }
      if (value is int) {
        value = value.toString();
      }
      baseInfo[key] = Uri.encodeQueryComponent(value);
    });
    baseInfo.keys.toList().forEach((key) => sigList.add("$key=${baseInfo[key]}"));
    sigList.sort();
    String queryString = sigList.join('&');
    String str = [
      method,
      _fqdn,
      path(className, objectId: objectId, definePath: definePath),
      queryString
    ].join("\n");
    List<int> key = utf8.encode(_ncmb!.clientKey!);
    Hmac hmac = new Hmac(sha256, key);
    return base64Encode(hmac.convert(str.codeUnits).bytes);
  }
}