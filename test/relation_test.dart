import 'package:flutter_test/flutter_test.dart';
import '../lib/ncmb.dart';
import 'dart:io';
import 'dart:convert';

Map keys = {};

void main() {
  setUp(() async {
    var path = 'example/keys.json';
    var file = File('../$path');
    var str = (await file.exists())
        ? await file.readAsString()
        : await File('./$path').readAsString();
    keys = json.decode(str);
    NCMB(keys['applicationKey'], keys['clientKey']);
  });

  group('Relation test', () {
    test("Add obj", () async {
      var r = NCMBRelation();
      var obj = NCMBObject('Test');
      obj.set('name', 'Hello');
      await obj.save();
      r.add(obj);
      var obj2 = NCMBObject('Test');
      obj2.set('name', 'Hello 2');
      await obj2.save();
      r.add(obj2);
      var obj3 = NCMBObject('Main');
      obj3.set('tests', r);
      await obj3.save();
      expect(obj3.get('objectId') != null, true);
    });

    test('Retrive data from relation', () async {
      var mainQ = NCMBQuery('Main');
      var obj = await mainQ.fetch();
      var query = NCMBQuery('Test');
      query.relatedTo(obj, 'tests');
      var ary = await query.fetchAll();
      expect(ary.length, 2);
      var r = NCMBRelation();
      r.remove(ary[0]);
      obj.set('tests', r);
      await obj.save();

      var ary2 = await query.fetchAll();
      expect(ary2.length, 1);

      var query2 = NCMBQuery('Test');
      var ary3 = await query2.fetchAll();
      expect(ary3.length, 2);
      await obj.delete();
    });
  });

  tearDownAll(() async {
    var query = new NCMBQuery('Test');
    query
      ..limit(100)
      ..fetchAll();
    var items = await query.fetchAll() ;
    for (NCMBObject o in items) {
      await o.delete();
    }
    query = new NCMBQuery('Main');
    query
      ..limit(100)
      ..fetchAll();
    items = await query.fetchAll();
    for (NCMBObject o in items) {
      await o.delete();
    }
  });
}
