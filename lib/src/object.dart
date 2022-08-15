// lib/src/object.dart

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

/// NCMBObject is a class for DataStore in NCMB.
class NCMBObject {
  /// For accessing to NCMB
  static NCMB? ncmb;

  /// Class name
  String _name = '';

  /// Fields data
  Map _fields = {};

  /// ObjectId
  String? objectId;

  /// Initializing NCMBObjct. Required class name.
  NCMBObject(this._name, {Map fields = const {}}) {
    fields.forEach((key, value) {
      _fields[key] = fields[key];
    });
  }

  /// Accessor methods. We can get class name by obj.name
  get name => _name;

  /// Accessor methods. We can get fields data by obj.fields
  get fields => _fields;

  /// Set [name] and [value] to fields.
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

  /// Call set methods for each key and value in [map]
  void sets(Map map) {
    map.removeWhere((k, v) => v == null);
    map.forEach((k, v) => set(k, v));
  }

  /// Fetch a data from DataStore in NCMB.
  /// After fetched data, set to own fields from data.
  Future<void> fetch() async {
    if (!_fields.containsKey('objectId')) {
      throw Exception('ObjectId is required.');
    }
    NCMBRequest r = new NCMBRequest();
    Map response = await r.exec('GET', _name, objectId: get('objectId'));
    sets(response);
  }

  // Increment update [name] fields. [number] is count to update(1 is default).
  void increment(String name, {int number = 1}) {
    if (!_fields.containsKey('objectId')) {
      return set(name, number);
    }
    set(name, {'__op': 'Increment', 'amount': number});
  }

  void add(String name, Object value) {
    if (!_fields.containsKey('objectId')) {
      return set(name, value);
    }
    if (!(value is List)) {
      value = [value];
    }
    set(name, {'__op': 'Add', 'objects': value});
  }

  void addUnique(String name, Object value) {
    if (!_fields.containsKey('objectId')) {
      return set(name, value);
    }
    if (!(value is List)) {
      value = [value];
    }
    set(name, {'__op': 'AddUnique', 'objects': value});
  }

  void remove(String name, Object value) {
    if (!_fields.containsKey('objectId')) {
      return set(name, value);
    }
    if (!(value is List)) {
      value = [value];
    }
    set(name, {'__op': 'Remove', 'objects': value});
  }

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

  Future<bool> delete() async {
    if (!_fields.containsKey('objectId')) {
      throw Exception('objectId is not found.');
    }
    NCMBRequest r = new NCMBRequest();
    Map res = await r.delete(_name, _fields['objectId']);
    return res.keys.length == 0;
  }

  bool hasKey(String name) {
    return _fields.containsKey(name);
  }

  Object? get(String name) {
    return _fields[name];
  }

  String getString(String name, {String? defaultValue}) {
    if (!_fields.containsKey(name) && defaultValue != null) return defaultValue;
    return _fields[name]! as String;
  }

  DateTime getDateTime(String name, {DateTime? defaultValue}) {
    if (!_fields.containsKey(name) && defaultValue != null) return defaultValue;
    return _fields[name]! as DateTime;
  }

  int getInt(String name, {int? defaultValue}) {
    if (!_fields.containsKey(name) && defaultValue != null) return defaultValue;
    return _fields[name]! as int;
  }

  double getDouble(String name, {double? defaultValue}) {
    if (!_fields.containsKey(name) && defaultValue != null) return defaultValue;
    return _fields[name]! as double;
  }

  bool getBool(String name, {bool? defaultValue}) {
    if (!_fields.containsKey(name) && defaultValue != null) return defaultValue;
    return _fields[name]! as bool;
  }

  List<dynamic> getList(String name, {List<dynamic>? defaultValue}) {
    if (!_fields.containsKey(name) && defaultValue != null) return defaultValue;
    return _fields[name]! as List;
  }

  dynamic toJson() {
    return {
      '__type': 'Pointer',
      'className': _name,
      'objectId': _fields['objectId']
    };
  }

  String toString() {
    return json.encode(_fields, toEncodable: myEncode);
  }

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
