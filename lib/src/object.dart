// lib/src/object.dart

import 'main.dart';
import 'dart:convert';
import 'dart:async';
import 'acl.dart';
import 'request.dart';
import 'geopoint.dart';
import 'package:intl/intl.dart';
import 'relation.dart';

/// NCMBObject is a class for DataStore in NCMB.
class NCMBObject {
  /// For accessing to NCMB
  static NCMB? ncmb;

  /// Class name
  String _name = '';

  /// Fields data
  Map _fields = {};

  /// Initializing NCMBObjct. Required class name.
  NCMBObject(this._name, {Map fields = const {}}) {
    _fields = {};
  }

  /// Accessor methods. We can get class name by obj.name
  get name => _name;

  /// Accessor methods. We can get fields data by obj.fields
  get fields => _fields;

  /// Set [name] and [value] to fields.
  void set(String name, Object value) {
    if (name == 'createDate' || name == 'updateDate') {
      value = DateTime.parse(value as String);
    }
    if (name == 'acl') {
      if (!(value is NCMBAcl)) {
        var acl = new NCMBAcl();
        acl.sets(value as Map);
        value = acl;
      }
    }
    if (value.runtimeType.toString() == '_JsonMap' ||
        value.runtimeType.toString() ==
            '_InternalLinkedHashMap<String, dynamic>') {
      var map = value as Map;
      if (map['className'] != null) {
        NCMBObject obj = NCMBObject(map['className']);
        map.remove('className');
        map.remove('__type');
        obj.sets(map);
        value = obj;
      }
      if (map.containsKey('__type') && map['__type'] == 'GeoPoint') {
        var geo = NCMBGeoPoint(
            map['latitude'].toDouble(), map['longitude'].toDouble());
        value = geo;
      }
      if (map.containsKey('__type') && map['__type'] == 'Date') {
        var format = new DateFormat("yyyy-MM-ddTHH:mm:ss.S'Z'");
        value = format.parseStrict(map['iso']);
      }
    }
    _fields[name] = value;
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

  Object get(String name) {
    return _fields[name];
  }

  String getString(String name) {
    return _fields[name]! as String;
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
      return item.toIso8601String();
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
