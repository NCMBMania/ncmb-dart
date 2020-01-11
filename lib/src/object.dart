part of ncmb;

class NCMBObject {
  String _name;
  Map _fields;
  NCMB _ncmb;
  
  NCMBObject(NCMB ncmb, String name) {
    this._ncmb = ncmb;
    this._name = name;
    this._fields = {};
  }
  
  void set(String name, Object value) {
    this._fields[name] = value;
  }
  
  Future<void> save() async {
    if (!this._fields.containsKey('objectId')) {
      NCMBRequest r = new NCMBRequest(this._ncmb);
      Map response = await r.post(this._name, this._fields);
      response.forEach((key, value) => this.set(key, value));
    }
    return true;
  }
  
  Object get(String name) {
    return this._fields[name];
  }
}
