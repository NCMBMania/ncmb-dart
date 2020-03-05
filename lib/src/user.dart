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
    _ncmb.sessionToken = response['sessionToken'];
    response.removeWhere((k, v) => k == 'sessionToken');
    _currentUser = NCMBUser(_ncmb);
    _currentUser.sets(response);
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
    _ncmb.sessionToken = response['sessionToken'];
    response.removeWhere((k, v) => k == 'sessionToken');
    _currentUser = NCMBUser(_ncmb);
    _currentUser.sets(response);
    return _currentUser;
  }
  
  void logout() {
    _ncmb.sessionToken = null;
  }
  
  NCMBUser CurrentUser() {
    return _currentUser;
  }
  
  Future<NCMBUser> login(String userName, String password) async {
    _fields = {
      'userName': userName,
      'password': password
    };
    NCMBRequest r = new NCMBRequest(_ncmb);
    Map response = await r.exec('GET', _name, queries: _fields, path: 'login');
    _ncmb.sessionToken = response['sessionToken'];
    response.removeWhere((k, v) => k == 'sessionToken');
    _currentUser = NCMBUser(_ncmb);
    _currentUser.sets(response);
    return _currentUser;
  }
}