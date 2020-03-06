part of ncmb;

class NCMBUser extends NCMBObject {
  SharedPreferences _prefs;
  String _userKey = 'CurrentUser';
  String _sessionKey = 'SessionId';
  
  NCMBUser _currentUser;
  NCMBUser(NCMB ncmb) : super(ncmb, 'users');
  Future<NCMBUser> signUpByAccount(String userName, String password) async {
    _fields = {
      'userName': userName,
      'password': password
    };
    NCMBRequest r = new NCMBRequest(_ncmb);
    Map response = await r.post(_name, _fields);
    return await setLoginResponse(response);
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
    return await setLoginResponse(response);
  }
  
  Future<void> logout() async {
    _prefs = await SharedPreferences.getInstance();
    _ncmb.sessionToken = null;
    _prefs.remove(_userKey);
    _prefs.remove(_sessionKey);
  }
  
  Future<NCMBUser> CurrentUser() async {
    if (_currentUser != null) return _currentUser;
    _prefs = await SharedPreferences.getInstance();
    var string = _prefs.getString(_userKey);
    if (string != null) {
      _ncmb.sessionToken = _prefs.getString(_sessionKey);
      var user = NCMBUser(_ncmb);
      user.sets(json.decode(string));
      _currentUser = user;
    }
    return _currentUser;
  }
  
  Future<NCMBUser> login(String userName, String password) async {
    _fields = {
      'userName': userName,
      'password': password
    };
    NCMBRequest r = new NCMBRequest(_ncmb);
    Map response = await r.exec('GET', _name, queries: _fields, path: 'login');
    return setLoginResponse(response);
  }

  Future<NCMBUser> setLoginResponse(Map response) async {
    _ncmb.sessionToken = response['sessionToken'];
    response.removeWhere((k, v) => k == 'sessionToken');
    var user = NCMBUser(_ncmb);
    user.sets(response);
    _prefs = await SharedPreferences.getInstance();
    _prefs.setString(_userKey, user.toString());
    _prefs.setString(_sessionKey, _ncmb.sessionToken);
    return user;
  }
  
  Future<bool> enableSession() async {
    try {
      var query = _ncmb.Query('users');
      query
        ..equalTo('test', 'test');
      await query.fetch();
      return true;
    } catch (e) {
      return false;
    }
  }
  
}