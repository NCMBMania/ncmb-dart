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
  
  group('Query test', () {
    test("Fetch all", () async {
      var query = ncmb.Query('Item');
      var item = ncmb.Object('Item')
        ..set('msg', 'Hello World');
      await item.save();
      var items = await query.fetchAll();
      expect(items.length > 0, true);
    });
  });

  tearDown(() async {
    var query = ncmb.Query('Item');
    var items = await query.fetchAll();
    items.forEach((o) async {
      await o.destroy();
    });
  });
}