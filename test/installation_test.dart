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
    var str = (await file.exists()) ? await file.readAsString() : await File('./${path}').readAsString();
    keys = json.decode(str);
    NCMB(keys['applicationKey'], keys['clientKey']);
  });

  group('Installation test', () {
    test('Save installations', () async {
      var installation = NCMBInstallation();
      installation
        ..set('deviceToken', 'aaa')
        ..set('deviceType', 'ios');
      await installation.save();
      expect(installation.get('objectId') != '', true);
    });

    test('Fetch installations', () async {
      var installation = NCMBInstallation();
      installation
        ..set('deviceToken', 'bbb')
        ..set('deviceType', 'ios');
      await installation.save();
      expect(installation.get('objectId') != '', true);
      var installation2 = NCMBInstallation();
      installation2.set('objectId', installation.get('objectId'));
      await installation2.fetch();
      expect(installation.get('objectId'), installation2.get('objectId'));
    });

    test('Update installations', () async {
      var installation = NCMBInstallation();
      installation
        ..set('deviceToken', 'ccc')
        ..set('deviceType', 'ios');
      await installation.save();
      expect(installation.get('objectId') != '', true);
      installation
        ..set('another', 'value');
      await installation.save();
      var installation2 = NCMBInstallation();
      installation2.set('objectId', installation.get('objectId'));
      await installation2.fetch();
      expect(installation2.get('another'), 'value');
    });
  });

  tearDownAll(() async {
    var query = NCMBInstallation.query();
    var items = await query.fetchAll() as List<NCMBInstallation>;
    await Future.forEach(items, (NCMBInstallation o) async {
      await o.delete();
    });
  });
}
