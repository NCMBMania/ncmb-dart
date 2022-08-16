import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'object.dart';
import 'request.dart';
import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'query.dart';

class NCMBUser extends NCMBObject {
  static NCMB? ncmb;
  static SharedPreferences? _prefs;
  static String _userKey = 'CurrentUser';
  static String _sessionKey = 'SessionId';

  static NCMBUser? _currentUser;
  NCMBUser() : super('users');

  static Future<NCMBUser> signUpByAccount(
      String userName, String password) async {
    Map _fields = {'userName': userName, 'password': password};
    NCMBRequest r = new NCMBRequest();
    Map response = await r.post('users', _fields);
    _fields.remove('password');
    var user = NCMBUser();
    await user.setLoginResponse(response);
    return user;
  }

  static Future<NCMBUser> loginAsAnonymous({String id = ''}) async {
    var uuid = Uuid();
    if (id == '') {
      id = uuid.v4();
    }
    Map _fields = {
      'authData': {
        'anonymous': {'id': id}
      }
    };
    NCMBRequest r = new NCMBRequest();
    Map response = await r.post('users', _fields);
    var user = NCMBUser();
    await user.setLoginResponse(response);
    return user;
  }

  static Future<NCMBUser> loginWithMailAddress(
      String mailAddress, String password) async {
    var _fields = {'mailAddress': mailAddress, 'password': password};
    NCMBRequest r = new NCMBRequest();
    Map response =
        await r.exec('GET', 'users', queries: _fields, path: 'login');
    var user = NCMBUser();
    await user.setLoginResponse(response);
    return user;
  }

  static Future<NCMBUser> loginWith(String provider, Map data) async {
    NCMBRequest r = new NCMBRequest();
    var fields = {'authData': {}};
    fields['authData']![provider] = data;
    Map response = await r.post('users', fields);
    var user = NCMBUser();
    await user.setLoginResponse(response);
    return user;
  }

  static Future<void> requestSignUpEmail(String mailAddress) async {
    Map _fields = {'mailAddress': mailAddress};
    NCMBRequest r = new NCMBRequest();
    await r.exec('POST', 'users',
        fields: _fields, path: 'requestMailAddressUserEntry');
  }

  static Future<void> requestPasswordReset(String mailAddress) async {
    Map _fields = {'mailAddress': mailAddress};
    NCMBRequest r = new NCMBRequest();
    await r.exec('POST', 'users',
        fields: _fields, path: 'requestPasswordReset');
  }

  static Future<void> logout() async {
    NCMBUser.ncmb!.sessionToken = null;
    try {
      NCMBUser._prefs = await SharedPreferences.getInstance();
      NCMBUser._prefs!.remove(NCMBUser._userKey);
      NCMBUser._prefs!.remove(NCMBUser._sessionKey);
    } catch (e) {}
    return;
  }

  static Future<NCMBUser?> currentUser() async {
    if (NCMBUser._currentUser != null) return NCMBUser._currentUser;
    try {
      NCMBUser._prefs = await SharedPreferences.getInstance();
      var string = NCMBUser._prefs!.getString(NCMBUser._userKey);
      if (string != null) {
        NCMBUser.ncmb!.sessionToken =
            NCMBUser._prefs!.getString(NCMBUser._sessionKey);
        var user = NCMBUser();
        user.sets(json.decode(string));
        NCMBUser._currentUser = user;
      }
      return NCMBUser._currentUser;
    } catch (e) {
      return null;
    }
  }

  static Future<NCMBUser> login(String userName, String password) async {
    Map _fields = {'userName': userName, 'password': password};
    NCMBRequest r = new NCMBRequest();
    Map response =
        await r.exec('GET', 'users', queries: _fields, path: 'login');
    var user = NCMBUser();
    user.setLoginResponse(response);
    return user;
  }

  Future<void> setLoginResponse(Map response) async {
    NCMBUser.ncmb!.sessionToken = response['sessionToken'];
    response.removeWhere((k, v) => k == 'sessionToken');
    this.sets(response);
    try {
      _prefs = await SharedPreferences.getInstance();
      _prefs!.setString(_userKey, this.toString());
      _prefs!.setString(_sessionKey, NCMBUser.ncmb!.sessionToken!);
    } catch (e) {}
  }

  static NCMBQuery query() {
    return new NCMBQuery('users');
  }

  Map toJson() {
    return {
      '__type': 'Pointer',
      'className': 'user',
      'objectId': this.get('objectId')
    };
  }

  Future<void> save() async {
    await super.save();
    try {
      _prefs = await SharedPreferences.getInstance();
      _prefs!.setString(_userKey, this.toString());
    } catch (e) {}
  }

  Future<bool> enableSession() async {
    try {
      var query = NCMBUser.query();
      query..equalTo('test', 'test');
      await query.fetch();
      return true;
    } catch (e) {
      return false;
    }
  }
}
