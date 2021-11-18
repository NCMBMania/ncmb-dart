import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/ncmb.dart';
import 'dart:io';
import 'dart:convert';

Map keys = {};

void main() {
  setUp(() async {
    var path = 'example/keys.json';
    var file = File('../${path}');
    var str = (await file.exists())
        ? await file.readAsString()
        : await File('./${path}').readAsString();
    keys = json.decode(str);
    NCMB(keys['applicationKey'], keys['clientKey']);
  });

  group('push test', () {
    test('Save pushs', () async {
      var push = NCMBPush();
      push
        ..set('immediateDeliveryFlag', true)
        ..set('message', 'Hello');
      await push.save();
      expect(push.get('objectId') != '', true);
    });

    test('Fetch pushs', () async {
      var push = NCMBPush();
      push
        ..set('immediateDeliveryFlag', true)
        ..set('message', 'Hello');
      await push.save();
      expect(push.get('objectId') != '', true);
      var push2 = NCMBPush();
      push2.set('objectId', push.get('objectId'));
      await push2.fetch();
      expect(push.get('objectId'), push2.get('objectId'));
    });

    test('Update push', () async {
      var push = NCMBPush();
      push
        ..set('immediateDeliveryFlag', true)
        ..set('message', 'Hello');
      await push.save();
      expect(push.get('objectId') != '', true);
      push..set('message', 'Hello, world');
      await push.save();
      var push2 = NCMBPush();
      push2.set('objectId', push.get('objectId'));
      await push2.fetch();
      expect(push2.get('message'), 'Hello, world');
    });
  });

  tearDownAll(() async {
    var query = NCMBPush.query();
    var items = await query.fetchAll();
    for (NCMBPush o in items) {
      await o.delete();
    }
  });
}
