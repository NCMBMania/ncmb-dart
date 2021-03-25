part of ncmb;

class NCMBRole extends NCMBObject {
  static NCMB ncmb;

  NCMBRole(String roleName) : super.initWithParams('roles', {'roleName': roleName});

  void addRole(role) {
    var key = 'belongRole';
    add(key, role);
  }

  void addUser(user) {
    var key = 'belongUser';
    add(key, user);
  }

  Future<List> fetchRole() async {
    var query = NCMBRole.query();
    query.relatedTo(this, 'belongRole');
    return query.fetchAll();
  }

  Future<List> fetchUser() async {
    var query = NCMBUser.query();
    query.relatedTo(this, 'belongUser');
    return query.fetchAll();
  }

  void removeRole(role) {
    var key = 'belongRole';
    remove(key, role);
  }

  void removeUser(user) {
    var key = 'belongUser';
    remove(key, user);
  }

  void add(key, obj) {
    var exist = this._fields.keys.firstWhere((k) => k == key, orElse: () => null);
    if (exist == null || !(this._fields[key] is NCMBRelation)) {
      this._fields[key] = NCMBRelation();
    }
    this._fields[key].add(obj);
  }

  void remove(key, obj) {
    var exist = this._fields.keys.firstWhere((k) => k == key, orElse: () => null);
    if (exist == null || !(this._fields[key] is NCMBRelation)) {
      this._fields[key] = NCMBRelation();
    }
    this._fields[key].remove(obj);
  }

  static NCMBQuery query() {
    return NCMBQuery('roles');
  }

  Map toJson() {
    return {
      '__type': 'Pointer',
      'className': 'role',
      'objectId': this.get('objectId')
    };
  }

  @override
  Future<void> save() async {
    if (!(this._fields['belongUser'] is NCMBRelation)) {
      this._fields.remove('belongUser');
    }
    if (!(this._fields['belongRole'] is NCMBRelation)) {
      this._fields.remove('belongRole');
    }
    return super.save();
  }
}
