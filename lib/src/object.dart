part of ncmb;

class NCMBObject {
  static NCMB? ncmb;

  String _name = '';
  Map _fields = {};

  NCMBObject(this._name);

  get name => _name;

  NCMBObject.initWithParams(this._name, params) {
    this.sets(params);
  }

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
    if (value.runtimeType.toString() == '_HashSet<dynamic>') {
      var map = value as Map;
      if (map['className'] != null) {
        NCMBObject obj = NCMBObject(map['className']);
        map.remove('className');
        map.remove('__type');
        obj.sets(map);
        value = obj;
      }
    }
    _fields[name] = value;
  }

  String className() {
    return _name;
  }

  void sets(Map map) {
    map.removeWhere((k, v) => v == null);
    map.forEach((k, v) => set(k, v));
  }

  Future<void> fetch() async {
    if (!_fields.containsKey('objectId')) {
      throw Exception('ObjectId is required.');
    }
    NCMBRequest r = new NCMBRequest();
    Map response = await r.exec('GET', _name, objectId: get('objectId'));
    sets(response);
  }

  void increment(String name, int number) {
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
    if (item is NCMBAcl) {
      return item.toJson();
    }
    return item;
  }
}
