part of ncmb;

class Signature {
  NCMB _ncmb;
  String _fqdn = 'mbaas.api.nifcloud.com';
  String _signatureMethod = 'HmacSHA256';
  String _signatureVersion = '2';
  String _version = '2013-09-01';
  Map _baseInfo = {
    "SignatureVersion": "",
    "SignatureMethod": "",
    "X-NCMB-Application-Key": "",
    "X-NCMB-Timestamp": ""
  };
  
  Signature(NCMB ncmb) {
    this._ncmb = ncmb;
    this._baseInfo['SignatureVersion'] = this._signatureVersion;
    this._baseInfo['SignatureMethod'] = this._signatureMethod;
    this._baseInfo['X-NCMB-Application-Key'] = ncmb.applicationKey;
  }
  
  String path(className, {String objectId = ''}) {
    String path = "/${this._version}";
    if (['user', 'push', 'role', 'file'].indexOf(className) > -1) {
      path = "$path/$className";
    } else {
      path = "$path/classes/$className";
    }
    if (objectId != '')
      path = "$path/$objectId";
    return path;
  }
  
  String url(className, {String objectId = ''}) {
    return "https://${this._fqdn}${this.path(className, objectId: objectId)}";
  }
  
  String generate(String method, String className, DateTime time, {String objectId = '', Map queries = const {}}) {
    this._baseInfo['X-NCMB-Timestamp'] = time.toIso8601String();
    List sigList = [];
    queries.forEach((key, value) => this._baseInfo[key] = Uri.encodeQueryComponent(jsonEncode(value)));
    this._baseInfo.keys.toList().forEach((key) => sigList.add("$key=${this._baseInfo[key]}"));
    sigList.sort();
    String queryString = sigList.join('&');
    String str = [
      method,
      this._fqdn,
      this.path(className, objectId: objectId),
      queryString
    ].join("\n");
    List<int> key = utf8.encode(this._ncmb.clientKey);
    Hmac hmac = new Hmac(sha256, key);
    return base64Encode(hmac.convert(str.codeUnits).bytes);
  }
}