import 'main.dart';
import 'dart:convert';
import 'dart:async';
import 'acl.dart';
import 'request.dart';
import 'geopoint.dart';
import 'package:intl/intl.dart';
import 'relation.dart';
import 'user.dart';
import 'push.dart';
import 'installation.dart';

/// データストアのオブジェクトを扱うクラス
class NCMBObject {
  /// NCMBオブジェクト
  static NCMB? ncmb;

  /// クラス名
  String _name = '';

  /// フィールドデータ
  Map _fields = {};

  /// オブジェクトID
  String? objectId;

  /// コンストラクター
  /// [name] クラス名
  /// [fields] フィールドデータ。省略時は空のMap
  NCMBObject(this._name, {Map fields = const {}}) {
    fields.forEach((key, value) {
      _fields[key] = fields[key];
    });
  }

  /// アクセサメソッド。クラス名を返す
  get name => _name;

  /// アクセサメソッド。フィールドデータを返す
  get fields => _fields;

  /// フィールドデータをセットする
  /// [name] フィールド名
  /// [value] セットするデータ
  void set(String name, Object value) {
    if (name == 'createDate' || name == 'updateDate') {
      value = DateTime.parse(value as String);
      _fields[name] = value;
      return;
    }
    if (['NCMBUser', 'NCMBObject', 'NCMBFile', 'NCMBPush', 'NCMBInstallation']
            .indexOf(value.runtimeType.toString()) >
        -1) {
      _fields[name] = value;
      return;
    }
    if (name == 'objectId') {
      objectId = value as String;
      _fields[name] = value;
      return;
    }
    if (name == 'acl') {
      if (!(value is NCMBAcl)) {
        var acl = new NCMBAcl();
        acl.sets(value as Map);
        value = acl;
      }
      _fields[name] = value;
      return;
    }
    try {
      var map = value as Map;
      if (map.containsKey('className')) {
        var className = map['className'] as String;
        map.remove('__type');
        map.remove('className');
        print(className);
        switch (className) {
          case 'user':
            var user = NCMBUser();
            user.sets(map);
            value = user;
            break;
          case 'installation':
            var installation = NCMBInstallation();
            installation.sets(map);
            value = installation;
            break;
          case 'push':
            var push = NCMBPush();
            push.sets(map);
            value = push;
            break;
          default:
            NCMBObject obj = NCMBObject(className);
            obj.sets(map);
            value = obj;
        }
        _fields[name] = value;
        return;
      }
      if (map.containsKey('__type') && map['__type'] == 'GeoPoint') {
        var geo = NCMBGeoPoint(
            map['latitude'].toDouble(), map['longitude'].toDouble());
        _fields[name] = geo;
        return;
      } else if (map.containsKey('__type') && map['__type'] == 'Date') {
        var format = DateFormat("yyyy-MM-ddTHH:mm:ss.S'Z'");
        _fields[name] = format.parseStrict(map['iso']);
        return;
      }
    } catch (e) {
      _fields[name] = value;
    }
  }

  /// フィールドデータをまとめてセットする
  /// [map] フィールド名をキーにしたマップデータ
  void sets(Map map) {
    map.removeWhere((k, v) => v == null);
    map.forEach((k, v) => set(k, v));
  }

  /// フィールドデータを取得する
  /// 取得したデータは自分自身にセットする
  Future<void> fetch() async {
    if (!_fields.containsKey('objectId')) {
      throw Exception('ObjectId is required.');
    }
    NCMBRequest r = new NCMBRequest();
    Map response = await r.exec('GET', _name, objectId: get('objectId'));
    sets(response);
  }

  /// 指定したフィールドの値をインクリメンタルする設定にする
  /// [name] フィールド名
  /// [number] インクリメントする値。省略時は1
  void increment(String name, {int number = 1}) {
    if (!_fields.containsKey('objectId')) {
      return set(name, number);
    }
    set(name, {'__op': 'Increment', 'amount': number});
  }

  /// 指定したフィールドに値を追加する
  /// [name] フィールド名
  /// [value] 追加するオブジェクト
  void add(String name, Object value) {
    if (!_fields.containsKey('objectId')) {
      return set(name, value);
    }
    if (!(value is List)) {
      value = [value];
    }
    set(name, {'__op': 'Add', 'objects': value});
  }

  /// 指定したフィールドに値を追加する（すでにある場合は追加しない）
  /// [name] フィールド名
  /// [value] 追加するオブジェクト
  void addUnique(String name, Object value) {
    if (!_fields.containsKey('objectId')) {
      return set(name, value);
    }
    if (!(value is List)) {
      value = [value];
    }
    set(name, {'__op': 'AddUnique', 'objects': value});
  }

  /// 指定したフィールドの値を削除する
  /// [name] フィールド名
  /// [value] 削除するオブジェクト
  void remove(String name, Object value) {
    if (!_fields.containsKey('objectId')) {
      return set(name, value);
    }
    if (!(value is List)) {
      value = [value];
    }
    set(name, {'__op': 'Remove', 'objects': value});
  }

  /// 指定したフィールドが存在するか確認する
  /// [name] フィールド名
  bool containsKey(String name) {
    return _fields.containsKey(name);
  }

  /// データを保存する
  Future<void> save() async {
    if (!_fields.containsKey('objectId')) {
      NCMBRequest r = new NCMBRequest();
      Map response = await r.post(_name, _fields);
      sets(response);
    } else {
      NCMBRequest r = new NCMBRequest();
      Map response = await r.put(_name, _fields['objectId'], _fields);
      sets(response);
    }
  }

  /// データを削除する
  Future<bool> delete() async {
    if (!_fields.containsKey('objectId')) {
      throw Exception('objectId is not found.');
    }
    NCMBRequest r = new NCMBRequest();
    Map res = await r.delete(_name, _fields['objectId']);
    return res.keys.length == 0;
  }

  /// 指定したフィールドが存在するか確認する
  /// [name] フィールド名
  bool hasKey(String name) {
    return _fields.containsKey(name);
  }

  /// 指定したフィールドの値を返す
  /// [name] フィールド名
  Object? get(String name) {
    return _fields[name];
  }

  /// 指定したフィールドの値を文字列型として返す
  /// [name] フィールド名
  /// [defaultValue] デフォルト値
  String getString(String name, {String? defaultValue}) {
    if (!_fields.containsKey(name) && defaultValue != null) return defaultValue;
    return _fields[name]! as String;
  }

  /// 指定したフィールドの値を日時型として返す
  /// [name] フィールド名
  /// [defaultValue] デフォルト値
  DateTime getDateTime(String name, {DateTime? defaultValue}) {
    if (!_fields.containsKey(name) && defaultValue != null) return defaultValue;
    return _fields[name]! as DateTime;
  }

  /// 指定したフィールドの値を数値型（int）として返す
  /// [name] フィールド名
  /// [defaultValue] デフォルト値
  int getInt(String name, {int? defaultValue}) {
    if (!_fields.containsKey(name) && defaultValue != null) return defaultValue;
    return _fields[name]! as int;
  }

  /// 挻定したフィールドの値を数値型（double）として返す
  /// [name] フィールド名
  /// [defaultValue] デフォルト値
  double getDouble(String name, {double? defaultValue}) {
    if (!_fields.containsKey(name) && defaultValue != null) return defaultValue;
    if (_fields[name].runtimeType == int) {
      return (_fields[name] as int).toDouble();
    }
    return _fields[name]! as double;
  }

  /// 指定したフィールドの値を真偽値として返す
  /// [name] フィールド名
  /// [defaultValue] デフォルト値
  bool getBool(String name, {bool? defaultValue}) {
    if (!_fields.containsKey(name) && defaultValue != null) return defaultValue;
    return _fields[name]! as bool;
  }

  /// 指定したフィールドの値をリストとして返す
  /// [name] フィールド名
  /// [defaultValue] デフォルト値
  List<dynamic> getList(String name, {List<dynamic>? defaultValue}) {
    if (!_fields.containsKey(name) && defaultValue != null) return defaultValue;
    return _fields[name]! as List;
  }

  /// データをJSON化する
  dynamic toJson() {
    return {
      '__type': 'Pointer',
      'className': _name,
      'objectId': _fields['objectId']
    };
  }

  /// データを文字列化する
  String toString() {
    return json.encode(_fields, toEncodable: myEncode);
  }

  /// 文字列化する際に利用するエンコード関数
  dynamic myEncode(dynamic item) {
    if (item is DateTime) {
      return item.toUtc().toIso8601String();
    }
    if (item is NCMBAcl ||
        item is NCMBGeoPoint ||
        item is NCMBObject ||
        item is NCMBRelation) {
      return item.toJson();
    }
    return item;
  }
}
