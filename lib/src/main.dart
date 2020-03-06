part of ncmb;

class NCMB {
  String applicationKey;
  String clientKey;
  String sessionToken;
  String version = '0.1.2';
  SharedPreferences _prefs;
  String _userKey = 'CurrentUser';
  String _sessionKey = 'SessionId';
  NCMBUser User;
  NCMBInstallation Installation;
  NCMBFile File;
  
  NCMB(String applicationKey, String clientKey) {
    this.applicationKey = applicationKey;
    this.clientKey = clientKey;
    this.User = NCMBUser(this);
    this.Installation = NCMBInstallation(this);
    this.File = NCMBFile(this);
    _prefs = await SharedPreferences.getInstance();
    var string = _prefs.getString(_userKey);
    if (string != '') {
      sessionToken = _prefs.getString(_sessionKey);
      var user = NCMBUser(this);
      user.sets(json.decode(string));
      this.User.currentUser = user;
    }
  }
  
  NCMBObject Object(name) {
    return new NCMBObject(this, name);
  }
  
  NCMBQuery Query(name) {
    return new NCMBQuery(this, name);
  }
  
  NCMBAcl Acl() {
    return new NCMBAcl();
  }
  
  NCMBGeoPoint GeoPoint(double lat, double lng) {
    return NCMBGeoPoint(lat, lng);
  }
  
  NCMBUser setLoginResponse(Map response) {
    sessionToken = response['sessionToken'];
    response.removeWhere((k, v) => k == 'sessionToken');
    var user = NCMBUser(this);
    user.sets(response);
    _prefs.setString(_userKey, user.toString());
    _prefs.setString(_sessionKey, sessionToken);
    return user;
  }
  
  Feature<bool> enableSession() async {
    var res = await User.equalTo('test', 'test').fetch();
    return res ? true : false;
  }
  
  void clear_prefs() {
    _prefs.remove(_userKey);
    _prefs.remove(_sessionKey);
  }
}
