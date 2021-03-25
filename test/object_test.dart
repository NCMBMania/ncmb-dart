import 'package:flutter_test/flutter_test.dart';
import '../lib/ncmb.dart';
import 'dart:io';
import 'dart:convert';

NCMB ncmb;

void main() {
  setUp(() async {
    String str = await File('./example/keys.json').readAsString();
    Map keys = json.decode(str);
    ncmb = NCMB(keys['applicationKey'], keys['clientKey']);
  });
  
  group('Object test', () {
    test("Save data", () async {
      var acl = ncmb.Acl();
      acl
        ..setPublicReadAccess(false)
        ..setPublicWriteAccess(true)
        ..setUserReadAccess('aaa', true);
      var item = ncmb.Object('Item')
        ..set('msg', 'Hello World')
        ..set('array', ['a', 'b'])
        ..set('int', 1)
        ..set('acl', acl)
        ..set('name', 'Atsushi');
      await item.save();
      print(item.get('objectId'));
      expect(item.get('objectId') != null, true);
    });
    
    test('Update date', () async {
      var item = ncmb.Object('Item')
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
      var item = ncmb.Object('Item')
        ..set('msg', 'Hello World')
        ..set('array', ['a', 'b'])
        ..set('int', 1)
        ..set('name', 'Atsushi');
      await item.save();
      var bol = await item.destroy();
      expect(bol, true);
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