part of ncmb;

class NCMBObject {
  String _name;
  Map _fields = {};
  NCMB _ncmb;
  
  NCMBObject(this._ncmb, this._name);
  
  void set(String name, Object value) {
    if (name == 'createDate' || name == 'updateDate') {
      value = DateTime.parse(value);
    }
    if (name == 'acl') {
      if (!(value is NCMBAcl)) {
        var acl = new NCMBAcl();
        acl.sets(value);
        value = acl;
      }
    }
    _fields[name] = value;
  }
  
  void sets(Map map) {
    map.forEach((k, v) => set(k, v));
  }
  
  Future<void> save() async {
    if (!_fields.containsKey('objectId')) {
      NCMBRequest r = new NCMBRequest(_ncmb);
      Map response = await r.post(_name, _fields);
      sets(response);
    } else {
      NCMBRequest r = new NCMBRequest(_ncmb);
      Map response = await r.put(_name, _fields['objectId'], _fields);
      sets(response);
    }
    return true;
  }
  
  Future<bool> destroy() async {
    if (!_fields.containsKey('objectId')) {
      throw Exception('objectId is not found.');
    }
    NCMBRequest r = new NCMBRequest(_ncmb);
    Map res = await r.delete(_name, _fields['objectId']);
    return res.keys.length == 0;
  }
  
  Object get(String name) {
    return _fields[name];
  }
  
  dynamic toJson() {
    return {
      '__type':'Pointer',
      'className':_name,
      'objectId': _fields['objectId']
    };
  }

  String toString() {
    return json.encode(_fields, toEncodable: myEncode);
  }
  
  dynamic myEncode(dynamic item) {
    if(item is DateTime) {
      return item.toIso8601String();
    }
    return item;
  }
}
