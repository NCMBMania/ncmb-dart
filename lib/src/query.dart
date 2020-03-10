part of ncmb;

class NCMBQuery {
  String _name;
  NCMB _ncmb;
  Map _queries;
  NCMBQuery(NCMB ncmb, String name) {
    _ncmb = ncmb;
    _name = name;
    _queries = {};
  }
  
  void clear() {
    _queries = {};
  }
  
  Future<NCMBObject> fetch() async {
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
      var r = new NCMBRequest(_ncmb);
      List ary = await r.get(_name, _queries);
      List<NCMBObject> results = [];
      ary.forEach((item) {
        var obj = new NCMBObject(_ncmb, _name);
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

  void allInArray(String key, Object value) {
    setOperand(key, value, ope: '\$all');
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
  
  void setOperand(String key, Object value, {String ope = ''}) {
    initWhere();
    if (value.runtimeType == NCMBObject) {
      var obj = value as NCMBObject;
      value = {
        '__type': 'Pointer',
        'className': obj.className(),
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
