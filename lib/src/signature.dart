part of ncmb;

class Signature {
  NCMB _ncmb;
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
  
  String path(className, {String objectId = ''}) {
    String path = "/${_version}";
    if (['user', 'push', 'role', 'file'].indexOf(className) > -1) {
      path = "$path/$className";
    } else {
      path = "$path/classes/$className";
    }
    if (objectId != '')
      path = "$path/$objectId";
    return path;
  }
  
  String url(className, {String objectId = '', Map queries = const {}}) {
    List queryList = [];
    queries.forEach((key, value) => queryList.add("$key=${Uri.encodeQueryComponent(jsonEncode(value))}"));
    String queryString = queryList.length == 0 ? '' : "?${queryList.join('&')}";
    return "https://${_fqdn}${path(className, objectId: objectId)}$queryString";
  }
  
  String generate(String method, String className, DateTime time, {String objectId = '', Map queries = const {}}) {
    baseInfo['X-NCMB-Timestamp'] = time.toIso8601String();
    List sigList = [];
    queries.forEach((key, value) => baseInfo[key] = Uri.encodeQueryComponent(jsonEncode(value)));
    baseInfo.keys.toList().forEach((key) => sigList.add("$key=${baseInfo[key]}"));
    sigList.sort();
    String queryString = sigList.join('&');
    String str = [
      method,
      _fqdn,
      path(className, objectId: objectId),
      queryString
    ].join("\n");
    List<int> key = utf8.encode(_ncmb.clientKey);
    Hmac hmac = new Hmac(sha256, key);
    return base64Encode(hmac.convert(str.codeUnits).bytes);
  }
}