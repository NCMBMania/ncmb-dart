import 'package:flutter_test/flutter_test.dart';
import '../lib/ncmb.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  setUp(() async {
    var path = 'example/keys.json';
    var file = File('../${path}');
    var str = (await file.exists()) ? await file.readAsString() : await File('./${path}').readAsString();
    Map keys = json.decode(str);
    NCMB ncmb = NCMB(keys['applicationKey'], keys['clientKey']);
  });
  
  group('Object test', () {
    test("Save data", () async {
      var acl = NCMBAcl();
      acl
        ..setPublicReadAccess(false)
        ..setPublicWriteAccess(true);
      var item = new NCMBObject('Item')
        ..set('msg', 'Hello World')
        ..set('array', ['a', 'b'])
        ..set('int', 1)
        ..set('acl', acl)
        ..set('name', 'Atsushi');
      await item.save();
      expect(item.get('objectId') != null, true);
    });
    
    test('Update date', () async {
      var item = new NCMBObject('Item')
        ..set('msg', 'Hello World')
        ..set('array', ['a', 'b'])
        ..set('int', 1)
        ..set('name', 'Atsushi');
      await item.save();
      // Update data
      item.set('name', 'goofmint');
      await item.save();
      expect(item.get('updateDate') != null, true);
    });
    
    test('Delete data', () async {
      var item = new NCMBObject('Item')
        ..set('msg', 'Hello World')
        ..set('array', ['a', 'b'])
        ..set('int', 1)
        ..set('name', 'Atsushi');
      await item.save();
      var bol = await item.delete();
      expect(bol, true);
    });

    test('Fetch data', () async {
      var message = 'Hello World';
      var item = new NCMBObject('Item')
        ..set('msg', message);
      await item.save();
      var item2 = new NCMBObject('Item');
      item2.set('objectId', item.get('objectId'));
      await item2.fetch();
      expect(item.get('msg'), item2.get('msg'));
    });

    test('Increment data', () async {
      var item = new NCMBObject('Item')
        ..set('number', 1);
      await item.save();
      item.increment('number', 2);
      await item.save();
      await item.fetch();
      expect(item.get('number'), 3);
    });

    test('Add data', () async {
      var item = new NCMBObject('Item')
        ..set('ary', ['a']);
      await item.save();
      item.add('ary', '4');
      await item.save();
      await item.fetch();
      expect(item.get('ary'), ['a', '4']);
    });

    test('Add unique data', () async {
      var item = new NCMBObject('Item')
        ..set('ary', ['a', 'b', 'c', 'd']);
      await item.save();
      item.addUnique('ary', ['a', 'e']);
      await item.save();
      await item.fetch();
      expect(item.get('ary'), ['a', 'b', 'c', 'd', 'e']);
    });

    test('Remove data', () async {
      var item = new NCMBObject('Item')
        ..set('ary', ['a', 'b', 'c', 'd']);
      await item.save();
      item.remove('ary', ['a', 'e']);
      await item.save();
      await item.fetch();
      expect(item.get('ary'), ['b', 'c', 'd']);
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