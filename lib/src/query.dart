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

/// データストアの検索を扱うクラス
class NCMBQuery {
  /// NCMBオブジェクト
  static NCMB? ncmb;

  /// クラス名
  String _name = '';

  /// 検索条件
  Map _queries = {};

  /// コンストラクター
  /// [name] クラス名
  NCMBQuery(String name) {
    _name = name;
  }

  /// 検索条件のクリア
  void clear() {
    _queries = {};
  }

  /// 最初の一件だけ取得する
  /// 検索結果はNCMBObjectやNCMBUser、NCMBFile、NCMBPush、NCMBInstallationのインスタンスとして返るので、
  /// ここではdynamic型で返す
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

  /// 検索を実行する
  /// 検索結果はNCMBObjectやNCMBUser、NCMBFile、NCMBPush、NCMBInstallationのインスタンスのリストとして返されるため、
  /// ここではdynamic型のリストで返す
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

  /// 検索条件の初期化
  void initWhere() {
    if (!_queries.containsKey('where')) _queries['where'] = {};
  }

  /// 指定したフィールドの値が指定した値と等しいことを検索条件に追加する
  /// [key] フィールド名
  /// [value] 検索する値
  void equalTo(String key, Object value) {
    setOperand(key, value);
  }

  /// 指定したフィールドの値が指定した値と等しくないことを検索条件に追加する
  /// [key] フィールド名
  /// [value] 検索する値
  void notEqualTo(String key, Object value) {
    setOperand(key, value, ope: '\$ne');
  }

  /// 指定したフィールドの値が指定した値より小さいことを検索条件に追加する
  /// [key] フィールド名
  /// [value] 検索する値
  void lessThan(String key, Object value) {
    setOperand(key, value, ope: '\$lt');
  }

  /// 指定したフィールドの値が指定した値より小さいか等しいことを検索条件に追加する
  /// [key] フィールド名
  /// [value] 検索する値
  void lessThanOrEqualTo(String key, Object value) {
    setOperand(key, value, ope: '\$lte');
  }

  /// 指定したフィールドの値が指定した値より大きいことを検索条件に追加する
  /// [key] フィールド名
  /// [value] 検索する値
  void greaterThan(String key, Object value) {
    setOperand(key, value, ope: '\$gt');
  }

  /// 指定したフィールドの値が指定した値より大きいか等しいことを検索条件に追加する
  /// [key] フィールド名
  /// [value] 検索する値
  void greaterThanOrEqualTo(String key, Object value) {
    setOperand(key, value, ope: '\$gte');
  }

  /// 指定したフィールドの値が指定した値の中に含まれることを検索条件に追加する
  /// [key] フィールド名
  /// [value] 検索する値
  void inValue(String key, Object value) {
    setOperand(key, value, ope: '\$in');
  }

  /// 指定したフィールドの値が指定した値の中に含まれないことを検索条件に追加する
  /// [key] フィールド名
  /// [value] 検索する値
  void notInValue(String key, Object value) {
    setOperand(key, value, ope: '\$nin');
  }

  /// 指定したフィールドの値が存在する（または存在しない）ことを検索条件に追加する
  /// [key] フィールド名
  /// [value] 検索する値（true:存在する、false:存在しない）
  void exists(String key, {bool value = true}) {
    setOperand(key, value, ope: '\$exists');
  }

  /// 指定したフィールドの値を正規表現で検索する
  /// [key] フィールド名
  /// [value] 正規表現
  void regex(String key, String value) {
    setOperand(key, value, ope: '\$regex');
  }

  /// 指定したフィールドの値が、指定した値のいずれかを含むことを検索条件に追加する
  /// [key] フィールド名
  /// [value] 検索する値
  void inArray(String key, Object value) {
    setOperand(key, value, ope: '\$inArray');
  }

  /// 指定したフィールドの値が、指定した値のいずれも含まないことを検索条件に追加する
  /// [key] フィールド名
  /// [value] 検索する値
  void notInArray(String key, Object value) {
    setOperand(key, value, ope: '\$notInArray');
  }

  /// 指定したフィールドの値が、指定した位置情報の近い順にデータを取得する
  /// [key] フィールド名
  /// [geo] 位置情報
  void near(String key, NCMBGeoPoint geo) {
    setOperand(key, geo.toJson(), ope: '\$nearSphere');
  }

  /// 指定したフィールドの値が、指定した位置情報の指定したキロメートル以内に存在することを検索条件に追加する
  /// [key] フィールド名
  /// [geo] 位置情報
  /// [maxDistance] 最大距離（キロメートル）
  void withinKilometers(String key, NCMBGeoPoint geo, double maxDistance) {
    setOperand(key, maxDistance, ope: '\$maxDistanceInKilometers');
    setOperand(key, geo.toJson(), ope: '\$nearSphere');
  }

  /// 指定したフィールドの値が、指定した位置情報の指定したマイル以内に存在することを検索条件に追加する
  /// [key] フィールド名
  /// [geo] 位置情報
  /// [maxDistance] 最大距離（マイル）
  void withinMiles(String key, NCMBGeoPoint geo, double maxDistance) {
    setOperand(key, maxDistance, ope: '\$maxDistanceInMiles');
    setOperand(key, geo.toJson(), ope: '\$nearSphere');
  }

  /// 指定したフィールドの値が、指定した位置情報の指定したラジアン以内に存在することを検索条件に追加する
  /// [key] フィールド名
  /// [geo] 位置情報
  /// [maxDistance] 最大距離（ラジアン）
  void withinRadians(String key, NCMBGeoPoint geo, double maxDistance) {
    setOperand(key, maxDistance, ope: '\$maxDistanceInRadians');
    setOperand(key, geo.toJson(), ope: '\$nearSphere');
  }

  /// 指定したフィールドの値が、指定した位置情報の指定した範囲内に存在することを検索条件に追加する
  /// [key] フィールド名
  /// [southWestVertex] 南西の位置情報（実際には四角の1点を示していればOK）
  /// [northEastVertex] 北東の位置情報（実際には四角の1点を示していればOK）
  void withinSquare(
      String key, NCMBGeoPoint southWestVertex, NCMBGeoPoint northEastVertex) {
    var box = {
      '\$box': [southWestVertex.toJson(), northEastVertex.toJson()]
    };
    setOperand(key, box, ope: '\$within');
  }

  // 指定したフィールドの値が、指定した値をすべて含んでいることを検索条件に追加する
  // [key] フィールド名
  // [value] 検索する値
  void allInArray(String key, Object value) {
    setOperand(key, value, ope: '\$all');
  }

  /// 指定したデータが、指定された親のリレーションにひもづく子のデータを取得
  /// [obj] 元データ
  /// [key] リレーションのフィールド名
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

  /// クエリー同士をOR検索する
  /// [queries] OR検索するクエリー
  void or(List<NCMBQuery> queries) {
    initWhere();
    _queries['where']['\$or'] = [];
    for (var i = 0; i < queries.length; i++) {
      var query = queries[i];
      _queries['where']['\$or'].add(query.where());
    }
  }

  /// 指定したフィールドを、別なクエリーの検索結果で絞り込む
  /// [key] フィールド名
  /// [subKey] 別なクエリーの検索対象とするフィールド名
  /// [query] 別なクエリー
  void select(String key, String subKey, NCMBQuery query) {
    initWhere();
    var className = '';
    switch (query._name) {
      case 'users':
        className = 'user';
        break;
      case 'roles':
        className = 'role';
        break;
      case 'installations':
        className = 'installation';
        break;
      case 'files':
        className = 'file';
        break;
      default:
        className = query._name;
        break;
    }
    _queries['where'][key] = {};
    var subQuery = query._queries;
    var params = {'className': className, 'where': subQuery['where']};
    if (subQuery.containsKey('limit')) {
      params['limit'] = subQuery['limit'];
    }
    if (subQuery.containsKey('skip')) {
      params['skip'] = subQuery['skip'];
    }
    _queries['where'][key]['\$select'] = {'query': params, 'key': subKey};
  }

  /// 指定したフィールド（ポインター）のデータを、検索結果に含める
  void include(String className) {
    if (!_queries.containsKey('include')) _queries['include'] = '';
    _queries['include'] = className;
  }

  /// 検索結果に総件数を含める
  void count() {
    _queries['count'] = 1;
  }

  /// 検索結果を、指定したフィールドでソートする
  /// [key] フィールド名
  /// [descending] 並び順（true: 昇順、false: 降順）。省略時は昇順
  void order(String key, {bool descending = true}) {
    var symbol = descending == true ? '-' : '';
    if (!_queries.containsKey('order')) {
      _queries['order'] = "$symbol$key";
    } else {
      _queries['order'] = "${_queries['order']},$symbol$key";
    }
  }

  /// 検索結果の取得件数を指定する
  /// [number] 取得件数。最大1000件まで。
  void limit(int number) {
    if (number < 1 || number > 1000) {
      throw Exception('Limit must be renge of 1~1000.');
    }
    _queries['limit'] = number;
  }

  /// 取得結果をスキップする
  /// limitと組み合わせてページネーションに利用できる
  /// [number] スキップする件数
  void skip(int number) {
    if (number < 1) {
      throw Exception('Skip must be greater than 0.');
    }
    _queries['skip'] = number;
  }

  /// クエリーをJSON化する
  Map toJson() {
    return _queries;
  }

  /// 検索条件を返す
  Map where() {
    initWhere();
    return _queries['where'];
  }

  /// 検索条件を設定する内部用関数
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
