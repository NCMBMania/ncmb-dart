part of ncmb;

class NCMBFile extends NCMBObject {
  NCMBFile(NCMB ncmb) : super(ncmb, 'files');
  
  Future<NCMBFile> upload(String fileName, dynamic blob, {acl = '', mimeType = ''}) async {
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
      acl = _ncmb.Acl()
        ..setPublicReadAccess(true)
        ..setPublicWriteAccess(true);
    }
    NCMBRequest r = new NCMBRequest(_ncmb);
    Map response = await r.exec('POST', _name, objectId: fileName, fields: {
      'acl': acl,
      'file': blob,
      'mimeType': MediaType(mime[0], mime[1])
    });
    var f = NCMBFile(_ncmb);
    f.sets(response);
    return f;
  }
}
