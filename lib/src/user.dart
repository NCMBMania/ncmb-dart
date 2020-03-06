part of ncmb;

class NCMBUser extends NCMBObject {
  NCMBUser _currentUser;
  NCMBUser(NCMB ncmb) : super(ncmb, 'users');
  Future<NCMBUser> signUpByAccount(String userName, String password) async {
    _fields = {
      'userName': userName,
      'password': password
    };
    NCMBRequest r = new NCMBRequest(_ncmb);
    Map response = await r.post(_name, _fields);
    return loginSuccess(response);
  }
  
  Future<NCMBUser> loginSuccess(Map response) async {
    _currentUser = _ncmb.setLoginResponse(response);
    return _currentUser;
  }
  
  Future<NCMBUser> loginAsAnonymous({String id = ''}) async {
    var uuid = Uuid();
    if (id == '') {
      id = uuid.v4();
    }
    _fields = {
      'authData': {
        'anonymous': {
          'id': id
        }
      }
    };
    NCMBRequest r = new NCMBRequest(_ncmb);
    Map response = await r.post(_name, _fields);
    return loginSuccess(response);
  }
  
  void logout() {
    _ncmb.clear_prefs();
  }
  
  NCMBUser CurrentUser() {
    return _currentUser;
  }
  
  String toString() {
    return json.encode(_fields);
  }
  
  Future<NCMBUser> login(String userName, String password) async {
    _fields = {
      'userName': userName,
      'password': password
    };
    NCMBRequest r = new NCMBRequest(_ncmb);
    Map response = await r.exec('GET', _name, queries: _fields, path: 'login');
    return loginSuccess(response);
  }
}