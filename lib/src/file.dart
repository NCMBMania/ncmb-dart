part of ncmb;

class NCMBFile extends NCMBObject {
  static NCMB ncmb;
  NCMBFile() : super('files');
  
  static Future<NCMBFile> upload(String fileName, dynamic blob, {acl = '', mimeType = ''}) async {
    List mime;
    if (mimeType == '') {
      if (blob is Uint8List) {
        mime = lookupMimeType('test', headerBytes: blob).split('/');
      } else {
        mime = ['text', 'plain'];
      }
    } else {
      mime = mimeType.split('/');
    }
    if (blob is! Uint8List) blob = utf8.encode(blob);
    
    if (acl == '') {
      acl = new NCMBAcl()
        ..setPublicReadAccess(true)
        ..setPublicWriteAccess(true);
    }
    NCMBRequest r = new NCMBRequest();
    Map response = await r.exec('POST', 'files', objectId: fileName, fields: {
      'acl': acl,
      'file': blob,
      'mimeType': MediaType(mime[0], mime[1]),
    }, multipart: true);
    var f = NCMBFile();
    f.sets(response);
    return f;
  }
  
  Future<NCMBFile> download(String fileName) async {
    NCMBRequest r = new NCMBRequest();
    Map response = await r.exec('GET', _name, objectId: fileName, multipart: true);
    var f = NCMBFile();
    f.set('blob', response['data']);
    return f;
  }

  static NCMBQuery query() {
    return NCMBQuery('files');
  }

  Future<bool> delete() async {
    if (!_fields.containsKey('fileName')) {
      throw Exception('fileName is not found.');
    }
    NCMBRequest r = new NCMBRequest();
    Map res = await r.delete(_name, _fields['fileName']);
    return res.keys.length == 0;
  }
}
