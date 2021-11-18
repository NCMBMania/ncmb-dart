import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/ncmb.dart';
import 'dart:io';
import 'dart:convert';

Map keys;

void main() {
  setUp(() async {
    var path = 'example/keys.json';
    var file = File('../$path');
    var str = (await file.exists())
        ? await file.readAsString()
        : await File('./$path').readAsString();
    keys = json.decode(str);
    NCMB(keys['applicationKey'], keys['clientKey']);
    SharedPreferences.setMockInitialValues({});
  });
  /*
  group('User test', () {
    test("Request register email", () async {
      await NCMBUser.requestSignUpEmail('atsushi@moongift.jp');
    });
  });
  */
  group('Sign up by account', () {
    test("User registered", () async {
      var user = NCMBUser();
      user..set('userName', 'aaa')..set('password', 'bbb');
      await user.signUpByAccount();
      expect(user.get('objectId') != '', true);
      await user.delete();
      await NCMBUser.logout();
    });

    test("User login", () async {
      var user = NCMBUser();
      user..set('userName', 'aaa')..set('password', 'bbb');
      await user.signUpByAccount();
      expect(user.get('objectId') != '', true);
      var user2 = await NCMBUser.login('aaa', 'bbb');
      expect(user.get('objectId'), user2.get('objectId'));
      await user.delete();
      await NCMBUser.logout();
    });

    test("Update user and fetch", () async {
      var user = NCMBUser();
      user..set('userName', 'aaa')..set('password', 'bbb');
      await user.signUpByAccount();
      try {
        user.set('testName', 'testValue');
        await user.save();
        var user2 = NCMBUser();
        user2.set('objectId', user.get('objectId'));
        await user2.fetch();
        expect(user2.get('testName'), 'testValue');
      } catch (e) {}
      await user.delete();
    });

    test("Retrive users", () async {
      var acl = NCMBAcl();
      acl
        ..setPublicReadAccess(true)
        ..setPublicWriteAccess(true);
      for (var i = 0; i < 5; i++) {
        var user = NCMBUser();
        user..set('userName', 'aaa$i')..set('password', 'bbb');
        await user.signUpByAccount();
        user.set('acl', acl);
        await user.save();
        await NCMBUser.logout();
      }
      var query = NCMBUser.query();
      query.limit(100);
      var ary = await query.fetchAll();
      print(ary);
      expect(ary.length, 5);
      await Future.forEach(ary, (u) async {
        await u.delete();
      });
      var ary2 = await query.fetchAll();
      expect(ary2.length, 0);
    });

    test("Login with email and password", () async {
      var mailAddress = keys['user']['mailAddress'];
      var password = keys['user']['password'];
      var user = await NCMBUser.loginWithMailAddress(mailAddress, password);
      expect(user.get('objectId') != '', true);
    });

    test("Sign in with facebook", () async {
      var facebookId = keys['user']['facebook']['id'];
      var accessToken = keys['user']['facebook']['accessToken'];
      var expirationDate = {
        "__type": "Date",
        "iso": keys['user']['facebook']['expiration_date']
      };
      var data = {
        'id': facebookId,
        'access_token': accessToken,
        'expiration_date': expirationDate
      };
      var user = await NCMBUser.loginWith('facebook', data);
      expect(user.get('objectId') != '', true);
      user.delete();
    });
  });
}
