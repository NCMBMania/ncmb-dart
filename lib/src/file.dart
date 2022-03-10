import 'package:mime/mime.dart';
import 'object.dart';
import 'request.dart';
import 'acl.dart';
import 'query.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';

class NCMBFile extends NCMBObject {
  NCMBFile() : super('files');

  static Future<NCMBFile> upload(String fileName, dynamic blob,
      {acl = '', mimeType = ''}) async {
    List mime;
    if (mimeType == '') {
      if (blob is Uint8List) {
        var res = lookupMimeType('test', headerBytes: blob);
        if (res != null) {
          mime = res.split('/');
        } else {
          mime = ['text', 'plain'];
        }
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
    Map response = await r.exec('POST', 'files',
        objectId: fileName,
        fields: {
          'acl': acl,
          'file': blob,
          'mimeType': MediaType(mime[0], mime[1]),
        },
        multipart: true);
    var f = NCMBFile();
    f.sets(response);
    return f;
  }

  static Future<NCMBFile> download(String fileName) async {
    NCMBRequest r = new NCMBRequest();
    Map response =
        await r.exec('GET', 'files', objectId: fileName, multipart: true);
    var f = NCMBFile();
    f.set('blob', response['data']);
    return f;
  }

  static NCMBQuery query() {
    return NCMBQuery('files');
  }

  Future<bool> delete() async {
    if (!super.hasKey('fileName')) {
      throw Exception('fileName is not found.');
    }
    NCMBRequest r = new NCMBRequest();
    Map res = await r.delete(super.name, super.getString('fileName'));
    return res.keys.length == 0;
  }
}
