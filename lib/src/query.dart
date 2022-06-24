import 'dart:async';

import 'main.dart';
import 'push.dart';
import 'file.dart';
import 'user.dart';
import 'role.dart';
import 'object.dart';
import 'installation.dart';
import 'request.dart';
import 'geopoint.dart';

class NCMBQuery {
  String _name = '';
  static NCMB? ncmb;
  Map _queries = {};
  NCMBQuery(String name) {
    _name = name;
  }

  void clear() {
    _queries = {};
  }

  Future fetch() async {
    try {
      _queries['limit'] = 1;
      var res = await fetchAll();
      if (res.length == 0) return null;
      return res[0];
    } catch (e) {
      throw e;
    }
  }

  Future<List> fetchAll() async {
    try {
      var r = new NCMBRequest();
      List ary = await r.get(_name, _queries);
      List results = [];
      ary.forEach((item) {
        var obj;
        switch (_name) {
          case 'files':
            obj = new NCMBFile();
            break;
          case 'users':
            obj = new NCMBUser();
            break;
          case 'roles':
            obj = new NCMBRole(item['roleName']);
            break;
          case 'installations':
            obj = new NCMBInstallation();
            break;
          case 'push':
            obj = new NCMBPush();
            break;
          default:
            obj = new NCMBObject(_name);
            break;
        }
        obj.sets(item);
        results.add(obj);
      });
      return results;
    } catch (e) {
      throw e;
    }
  }

  void initWhere() {
    if (!_queries.containsKey('where')) _queries['where'] = {};
  }

  void equalTo(String key, Object value) {
    setOperand(key, value);
  }

  void notEqualTo(String key, Object value) {
    setOperand(key, value, ope: '\$ne');
  }

  void lessThan(String key, Object value) {
    setOperand(key, value, ope: '\$lt');
  }

  void lessThanOrEqualTo(String key, Object value) {
    setOperand(key, value, ope: '\$lte');
  }

  void greaterThan(String key, Object value) {
    setOperand(key, value, ope: '\$gt');
  }

  void greaterThanOrEqualTo(String key, Object value) {
    setOperand(key, value, ope: '\$gte');
  }

  void inValue(String key, Object value) {
    setOperand(key, value, ope: '\$in');
  }

  void notInValue(String key, Object value) {
    setOperand(key, value, ope: '\$nin');
  }

  void exists(String key, {bool value = true}) {
    setOperand(key, value, ope: '\$exists');
  }

  void regex(String key, String value) {
    setOperand(key, value, ope: '\$regex');
  }

  void inArray(String key, Object value) {
    setOperand(key, value, ope: '\$inArray');
  }

  void notInArray(String key, Object value) {
    setOperand(key, value, ope: '\$notInArray');
  }

  void near(String key, NCMBGeoPoint geo) {
    setOperand(key, geo.toJson(), ope: '\$nearSphere');
  }

  void withinKilometers(String key, NCMBGeoPoint geo, double maxDistance) {
    setOperand(key, maxDistance, ope: '\$maxDistanceInKilometers');
    setOperand(key, geo.toJson(), ope: '\$nearSphere');
  }

  void withinMiles(String key, NCMBGeoPoint geo, double maxDistance) {
    setOperand(key, maxDistance, ope: '\$maxDistanceInMiles');
    setOperand(key, geo.toJson(), ope: '\$nearSphere');
  }

  void withinRadians(String key, NCMBGeoPoint geo, double maxDistance) {
    setOperand(key, maxDistance, ope: '\$maxDistanceInRadians');
    setOperand(key, geo.toJson(), ope: '\$nearSphere');
  }

  void withinSquare(
      String key, NCMBGeoPoint southWestVertex, NCMBGeoPoint northEastVertex) {
    var box = {
      '\$box': [southWestVertex.toJson(), northEastVertex.toJson()]
    };
    setOperand(key, box, ope: '\$within');
  }

  void allInArray(String key, Object value) {
    setOperand(key, value, ope: '\$all');
  }

  void relatedTo(obj, String key) {
    var className;
    if (obj is NCMBUser) {
      className = 'user';
    } else if (obj is NCMBRole) {
      className = 'role';
    } else if (obj is NCMBInstallation) {
      className = 'installation';
    } else {
      className = obj.name;
    }
    var query = {
      'object': {
        '__type': 'Pointer',
        'className': className,
        'objectId': obj.get('objectId')
      },
      'key': key
    };
    initWhere();
    _queries['where']['\$relatedTo'] = query;
  }

  void or(List<NCMBQuery> queries) {
    initWhere();
    _queries['where']['\$or'] = [];
    for (var i = 0; i < queries.length; i++) {
      var query = queries[i];
      _queries['where']['\$or'].add(query.where());
    }
  }

  void include(String className) {
    if (!_queries.containsKey('include')) _queries['include'] = '';
    _queries['include'] = className;
  }

  void count() {
    _queries['count'] = 1;
  }

  void order(String key, {bool descending = true}) {
    var symbol = descending == true ? '-' : '';
    if (!_queries.containsKey('order')) {
      _queries['order'] = "$symbol$key";
    } else {
      _queries['order'] = "${_queries['order']},$symbol$key";
    }
  }

  void limit(int number) {
    if (number < 1 || number > 1000) {
      throw Exception('Limit must be renge of 1~1000.');
    }
    _queries['limit'] = number;
  }

  void skip(int number) {
    if (number < 1) {
      throw Exception('Skip must be greater than 0.');
    }
    _queries['skip'] = number;
  }

  Map toJson() {
    return _queries;
  }

  Map where() {
    initWhere();
    return _queries['where'];
  }

  void setOperand(String key, Object value, {String ope = ''}) {
    initWhere();
    if (value.runtimeType == DateTime) {
      var v = value as DateTime;
      value = {
        '__type': 'Date',
        'iso': v.toUtc().toIso8601String(),
      };
    }
    if (value.runtimeType == NCMBObject) {
      var obj = value as NCMBObject;
      value = {
        '__type': 'Pointer',
        'className': obj.name,
        'objectId': obj.get('objectId')
      };
    }

    if (ope == '') {
      _queries['where'][key] = value;
    } else {
      if (!_queries['where'].containsKey(key)) _queries['where'][key] = {};
      _queries['where'][key][ope] = value;
    }
  }
}
