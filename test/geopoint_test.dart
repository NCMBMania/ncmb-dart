import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import '../lib/ncmb.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  setUpAll(() async {
    var path = 'example/keys.json';
    var file = File('../$path');
    var str = (await file.exists())
        ? await file.readAsString()
        : await File('./$path').readAsString();
    var keys = json.decode(str);
    NCMB(keys['applicationKey'], keys['clientKey']);

    var geoPath = 'example/yamanote.json';
    file = File('../$geoPath');
    str = (await file.exists())
        ? await file.readAsString()
        : await File('./$geoPath').readAsString();
    var ary = json.decode(str);
    for (var params in ary) {
      var geo = NCMBGeoPoint(
          double.parse(params['latitude']), double.parse(params['longitude']));
      var obj = NCMBObject('Station');
      obj
        ..set('name', params['name'])
        ..set('geo', geo);
      await obj.save();
    }
  });

  group('Object test', () {
    test("Near", () async {
      var geo = NCMBGeoPoint(35.6585805, 139.7454329);
      var query = NCMBQuery('Station');
      query
        ..near('geo', geo)
        ..limit(5);
      var results = await query.fetchAll();

      expect(results[0].get('name'), '浜松町');
      expect(results[4].get('name'), '東京');
    });
    test("withinKilometers", () async {
      var geo = NCMBGeoPoint(35.6585805, 139.7454329);
      var query = NCMBQuery('Station');
      query..withinKilometers('geo', geo, 1.5);
      var results = await query.fetchAll();
      expect(results.length, 3);
      expect(results[0].get('name'), '浜松町');
      expect(results[2].get('name'), '新橋');
    });

    test("withinKilometers", () async {
      var geo1 = NCMBGeoPoint(35.6500719, 139.7437146);
      var geo2 = NCMBGeoPoint(35.6695908, 139.761875);
      var query = NCMBQuery('Station');
      query..withinSquare('geo', geo1, geo2);
      var results = await query.fetchAll();
      expect(results.length, 2);
      expect(results[0].get('name'), '新橋');
      expect(results[1].get('name'), '浜松町');
    });
  });

  tearDownAll(() async {
    var query = NCMBQuery('Station');
    query.limit(100);
    var ary = await query.fetchAll();
    for (var result in ary) {
      await result.delete();
    }
  });
}
