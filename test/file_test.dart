import 'package:flutter_test/flutter_test.dart';
import '../lib/ncmb.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  setUp(() async {
    var path = 'example/keys.json';
    var file = File('../$path');
    var str = (await file.exists())
        ? await file.readAsString()
        : await File('./$path').readAsString();
    var keys = json.decode(str);
    NCMB(keys['applicationKey'], keys['clientKey']);
  });

  group('File test', () {
    test("Upload binary file", () async {
      var fileName = 'dart.png';
      var blob = await File('./test/' + fileName).readAsBytes();
      var file = await NCMBFile.upload(fileName, blob);
      expect(file.get('fileName'), fileName);
    });
    test("Upload text file", () async {
      var fileName = 'dart.txt';
      var file = await NCMBFile.upload(fileName, 'Hello world');
      expect(file.get('fileName'), fileName);
    });
    test("Upload csv file", () async {
      var fileName = 'dart.csv';
      var file = await NCMBFile.upload(fileName, 'a,b,c', mimeType: 'text/csv');
      expect(file.get('fileName'), fileName);
    });
  });

  group('File query test', () {
    test("Retribed all files", () async {
      var query = NCMBFile.query();
      var ary = await query.fetchAll();
      expect(ary[0] is NCMBFile, true);
      for (NCMBFile f in ary) {
        await f.delete();
      }
      var ary2 = await query.fetchAll();
      expect(ary2.length, 0);
    });
  });

  tearDown(() async {});
}
