class NCMBRelation {
  Map _fields = {};

  void add(obj) {
    var op = 'AddRelation';
    this.set(op, obj);
  }

  void remove(obj) {
    var op = 'RemoveRelation';
    this.set(op, obj);
  }

  void set(op, obj) {
    if (!(obj is List)) {
      obj = [obj];
    }
    var key =
        this._fields.keys.firstWhere((k) => k == '__op', orElse: () => null);
    if (key == null) {
      this._fields = {'__op': op, 'objects': []};
    }
    obj.forEach((o) {
      this._fields['objects'].add(o.toJson());
    });
  }

  Map toJson() {
    return this._fields;
  }
}
