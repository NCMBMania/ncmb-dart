import 'package:flutter_test/flutter_test.dart';
import '../lib/ncmb.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  setUp(() async {
    String str = await File('./example/keys.json').readAsString();
    Map keys = json.decode(str);
    NCMB(keys['applicationKey'], keys['clientKey']);
  });
  
  group('Query test', () {
    test("Fetch all", () async {
      var query = new NCMBQuery('Item');
      var item = new NCMBObject('Item')
        ..set('msg', 'Hello World');
      await item.save();
      var items = await query.fetchAll();
      expect(items.length > 0, true);
    });
 
    test("Fetch or", () async {
      var item = new NCMBObject('Item')
        ..set('num', 1);
      await item.save();
      item = new NCMBObject('Item')
        ..set('num', 2);
      await item.save();
      var query1 = new NCMBQuery('Item');
      query1.equalTo('num', 1);
      var query2 = new NCMBQuery('Item');
      query2.equalTo('num', 2);
      var query = new NCMBQuery('Item');
      query.or([query1, query2]);
      var items = await query.fetchAll();
      expect(items.length, 2);
    });
  });

  tearDown(() async {
    var query = new NCMBQuery('Item');
    var items = await query.fetchAll();
    items.forEach((o) async {
      await o.delete();
    });
  });
}