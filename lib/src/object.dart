part of ncmb;

class NCMBObject {
  String _name;
  Map _fields;
  NCMB _ncmb;
  
  NCMBObject(NCMB ncmb, String name) {
    _ncmb = ncmb;
    _name = name;
    _fields = {};
  }
  
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
      response.forEach((key, value) => set(key, value));
    } else {
      NCMBRequest r = new NCMBRequest(_ncmb);
      Map response = await r.put(_name, _fields['objectId'], _fields);
      response.forEach((key, value) => set(key, value));
    }
    return true;
  }
  
  Future<void> destroy() async {
    if (!_fields.containsKey('objectId')) {
      throw Exception('objectId is not found.');
    }
    NCMBRequest r = new NCMBRequest(_ncmb);
    await r.delete(_name, _fields['objectId']);
  }
  
  Object get(String name) {
    return _fields[name];
  }
}
