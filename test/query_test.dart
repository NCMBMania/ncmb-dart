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
      var item = new NCMBObject('Item')..set('msg', 'Hello World');
      await item.save();
      var items = await query.fetchAll();
      expect(items.length > 0, true);
    });

    test("Fetch by type", () async {
      var query = new NCMBQuery('Item');
      var array = ["100", "200", "300"];
      var msg = 'Hello World';
      var item = new NCMBObject('Item')
        ..set('msg', msg)
        ..set('num', 100)
        ..set('bool', false)
        ..set('array', array);
      await item.save();
      query.equalTo('objectId', item.objectId!);
      var result = await query.fetch();
      result = result as NCMBObject;
      expect(result.getBool('bool'), false);
      expect(result.getString('msg'), msg);
      expect(result.getInt('num'), 100);
      expect(result.getList('array', defaultValue: ['']), array);
    });

    test("Fetch date all", () async {
      var dt = DateTime.now();
      var query = new NCMBQuery('Item');
      query.lessThanOrEqualTo('createDate', dt);
      var items = await query.fetchAll();
      expect(items.length > 0, true);
    });

    test("Fetch or", () async {
      var item = new NCMBObject('Item')..set('num', 1);
      await item.save();
      item = new NCMBObject('Item')..set('num', 2);
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

    test("Fetch select", () async {
      for (var i = 1; i <= 3; i++) {
        var item = new NCMBObject('Group')..set('name', 'Group $i');
        await item.save();
      }
      for (var i = 1; i <= 6; i++) {
        var item = new NCMBObject('Member')..set('name', 'Member $i');
        if (i % 2 == 0) {
          item.set('group', 'Group 2');
        } else {
          item.set('group', 'Group 1');
        }
        await item.save();
      }
      try {
        var groupQuery = new NCMBQuery('Group');
        groupQuery.equalTo('name', 'Group 2');
        var memberQuery = new NCMBQuery('Member');
        memberQuery.select('group', 'name', groupQuery);
        var items = await memberQuery.fetchAll();
        expect(items.length, 3);
        items.forEach((item) {
          item = item as NCMBObject;
          expect(item.getString('group'), 'Group 2');
        });
      } catch (e) {
        print(e);
      }
    });
  });

  tearDown(() async {
    for (var className in ['Group', 'Member', 'Item']) {
      var query = new NCMBQuery(className);
      query.limit(1000);
      var items = await query.fetchAll();
      for (var item in items) {
        await item.delete();
      }
    }
  });
}
