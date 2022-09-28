import 'main.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// 署名を生成するクラス
class Signature {
  /// NCMBオブジェクト
  NCMB? _ncmb;

  /// FQDN
  final String _fqdn = 'mbaas.api.nifcloud.com';

  /// スクリプト用FQDN
  final String _scriptFqdn = 'script.mbaas.api.nifcloud.com';

  /// 署名用メソッド
  final String _signatureMethod = 'HmacSHA256';

  /// 署名のバージョン
  final String _signatureVersion = '2';

  /// APIバージョン
  final String _version = '2013-09-01';

  /// スクリプトAPIバージョン
  final String _scriptVersion = '2015-09-01';

  /// スクリプトかどうかのフラグ
  bool _isScript = false;

  /// 署名に必要な基本的な情報
  Map baseInfo = {
    "SignatureVersion": "",
    "SignatureMethod": "",
    "X-NCMB-Application-Key": "",
    "X-NCMB-Timestamp": ""
  };

  /// コンストラクタ
  /// [ncmb] NCMBオブジェクト
  /// [isScript] スクリプト用かどうか。省略時はfalse。
  Signature(NCMB ncmb, {bool isScript = false}) {
    _ncmb = ncmb;
    _isScript = isScript;
    baseInfo['SignatureVersion'] = _signatureVersion;
    baseInfo['SignatureMethod'] = _signatureMethod;
    baseInfo['X-NCMB-Application-Key'] = ncmb.applicationKey;
  }

  /// URLパスを返す
  /// [className] クラス名
  /// [objectId] オブジェクトID。省略時は空文字。
  /// [definePath] あらかじめ決まっているパス。省略時は空文字。
  String path(className, {objectId = '', definePath = ''}) {
    if (_isScript) {
      return '/$_scriptVersion/script/$className';
    }
    String path = "/$_version";
    if (definePath != '') {
      return "$path/$definePath";
    }
    if (['users', 'push', 'roles', 'files', 'installations']
            .indexOf(className) >
        -1) {
      path = "$path/$className";
    } else {
      path = "$path/classes/$className";
    }
    if (objectId != '') path = "$path/$objectId";
    return path;
  }

  /// リクエストするURLを返す
  /// [className] クラス名
  /// [objectId] オブジェクトID。省略時は空文字。
  /// [definePath] あらかじめ決まっているパス。省略時は空文字。
  /// [queries] クエリ。省略時は空のMap。
  String url(className, {objectId = '', queries = const {}, definePath = ''}) {
    List queryList = [];
    queries.forEach((key, value) {
      if (value is Map || value is List) {
        value = jsonEncode(value);
      }
      if (value is int) {
        value = value.toString();
      }
      queryList.add("$key=${Uri.encodeQueryComponent(value)}");
    });
    String queryString = queryList.length == 0 ? '' : "?${queryList.join('&')}";
    return "https://${fqdn()}${path(className, objectId: objectId, definePath: definePath)}$queryString";
  }

  /// FQDNを返す
  String fqdn() {
    return _isScript ? _scriptFqdn : _fqdn;
  }

  /// 署名を生成する
  /// [method] リクエストメソッド
  /// [className] クラス名
  /// [time] タイムスタンプ
  /// [objectId] オブジェクトID。省略時は空文字。
  /// [queries] クエリ。省略時は空のMap。
  /// [definePath] あらかじめ決まっているパス。省略時は空文字。
  String generate(String method, String className, DateTime time,
      {objectId = '', queries = const {}, definePath = ''}) {
    baseInfo['X-NCMB-Timestamp'] = time.toUtc().toIso8601String();
    List sigList = [];
    if (method == 'GET' || !_isScript) {
      queries.forEach((key, value) {
        if (value is Map || value is List) {
          value = jsonEncode(value);
        }
        if (value is int) {
          value = value.toString();
        }
        baseInfo[key] = Uri.encodeQueryComponent(value);
      });
    }
    baseInfo.keys
        .toList()
        .forEach((key) => sigList.add("$key=${baseInfo[key]}"));
    sigList.sort();
    String queryString = sigList.join('&');
    String str = [
      method,
      fqdn(),
      path(className, objectId: objectId, definePath: definePath),
      queryString
    ].join("\n");
    List<int> key = utf8.encode(_ncmb!.clientKey!);
    Hmac hmac = new Hmac(sha256, key);
    return base64Encode(hmac.convert(str.codeUnits).bytes);
  }
}
