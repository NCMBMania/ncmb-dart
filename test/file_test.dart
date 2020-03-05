import 'package:flutter_test/flutter_test.dart';
import '../lib/ncmb.dart';
import 'dart:io';
import 'dart:convert';

NCMB ncmb;

void main() {
  setUp(() async {
    String str = await File('../example/keys.json').readAsString();
    Map keys = json.decode(str);
    ncmb = NCMB(keys['applicationKey'], keys['clientKey']);
  });
  
  group('File test', () {
    test("Upload binary file", () async {
      var fileName = 'dart.png';
      var blob = await File(fileName).readAsBytes();
      var file = await ncmb.File.upload(fileName, blob);
      expect(file.get('fileName'), fileName);
    });
    test("Upload text file", () async {
      var fileName = 'dart.txt';
      var file = await ncmb.File.upload(fileName, 'Hello world');
      expect(file.get('fileName'), fileName);
    });
    test("Upload csv file", () async {
      var fileName = 'dart.csv';
      var file = await ncmb.File.upload(fileName, 'a,b,c', mimeType: 'text/csv');
      expect(file.get('fileName'), fileName);
    });
  });

  tearDown(() async {
  });
}