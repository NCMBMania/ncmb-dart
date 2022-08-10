import 'package:flutter_test/flutter_test.dart';
import '../lib/ncmb.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  setUp(() async {
    var path = 'example/keys.json';
    var file = File('../$path');
    var str = (await file.exists())
        ? await file.readAsString()
        : await File('./$path').readAsString();
    var keys = json.decode(str);
    NCMB(keys['applicationKey'], keys['clientKey']);
  });

  group('Script test', () {
    test("Get", () async {
      var script = NCMBScript('script_test_get.js');
      script.query('hoge', 'fuga');
      script.header('foo1', 'bar1');
      script.header('foo2', 'bar2');
      var result = await script.get() as Map<String, dynamic>;
      expect(result['query']['hoge'], 'fuga');
      expect(result['headers']['foo1'], 'bar1');
    });
    test("Delete", () async {
      var script = NCMBScript('script_test_delete.js');
      script.query('hoge', 'fuga');
      script.header('foo1', 'bar1');
      script.header('foo2', 'bar2');
      var result = await script.delete() as Map<dynamic, dynamic>;
      expect(result['query']['hoge'], 'fuga');
      expect(result['headers']['foo1'], 'bar1');
    });
    test("Post", () async {
      var script = NCMBScript('script_test_post.js');
      script.query('hoge1', 'fuga1');
      script.body('hoge2', 'fuga2');
      script.body('hoge3', 'fuga3');
      script.header('foo1', 'bar1');
      script.header('foo2', 'bar2');
      var result = await script.post() as Map<String, dynamic>;
      expect(result['query']['hoge1'], 'fuga1');
      expect(result['headers']['foo1'], 'bar1');
      expect(result['body']['hoge2'], 'fuga2');
      expect(result['body']['hoge3'], 'fuga3');
    });
    test("Put", () async {
      var script = NCMBScript('script_test_put.js');
      script.query('hoge1', 'fuga1');
      script.body('hoge2', 'fuga2');
      script.body('hoge3', 'fuga3');
      script.header('foo1', 'bar1');
      script.header('foo2', 'bar2');
      var result = await script.put() as Map<String, dynamic>;
      expect(result['query']['hoge1'], 'fuga1');
      expect(result['headers']['foo1'], 'bar1');
      expect(result['body']['hoge2'], 'fuga2');
      expect(result['body']['hoge3'], 'fuga3');
    });
  });
}
