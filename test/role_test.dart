import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/ncmb.dart';
import 'dart:io';
import 'dart:convert';

Map keys = {};

void main() {
  setUp(() async {
    var path = 'example/keys.json';
    var file = File('../$path');
    var str = (await file.exists())
        ? await file.readAsString()
        : await File('./$path').readAsString();
    keys = json.decode(str);
    NCMB(keys['applicationKey'], keys['clientKey']);
    var query = NCMBUser.query();
    var users = await query.fetchAll();
    for (NCMBUser u in users) {
      await u.delete();
    }
    SharedPreferences.setMockInitialValues({});
  });

  group('Role test', () {
    test('Set roleName', () async {
      var role = NCMBRole('Test');
      expect(role.get('roleName'), 'Test');
    });

    test('Add role to role', () async {
      var role = NCMBRole('RoleTest1');
      await role.save();
      expect(role.get('objectId') != null, true);
      var role2 = NCMBRole('RoleTest2');
      await role2.save();
      role.addRole(role2);
      await role.save();
      var roles = await role.fetchRole();
      expect(role2.get('objectId'), roles[0].get('objectId'));
    });

    test('add user to role', () async {
      var ary = [];
      var acl = NCMBAcl();
      acl
        ..setPublicReadAccess(true)
        ..setPublicWriteAccess(true);
      for (var i = 0; i < 5; i++) {
        var user = NCMBUser();
        user
          ..set('userName', 'aaa$i')
          ..set('password', 'bbb');
        await user.signUpByAccount();
        user.set('acl', acl);
        await user.save();
        ary.add(user);
        await NCMBUser.logout();
      }
      var role = NCMBRole('UserTest');
      await role.save();
      role.addUser(ary);
      await role.save();
      var users = await role.fetchUser();
      expect(users.length, 5);
    });

    test('Remove role from role', () async {
      var query = NCMBRole.query();
      query.equalTo('roleName', 'RoleTest1');
      var role1 = await query.fetch();
      query.equalTo('roleName', 'RoleTest2');
      var role2 = await query.fetch();
      role1.removeRole(role2);
      await role1.save();
      var roles = await role1.fetchRole();
      expect(roles.length, 0);
      await role1.delete();
      await role2.delete();
    });

    test('Remove user from role', () async {
      var query = NCMBRole.query();
      query.equalTo('roleName', 'UserTest');
      var role1 = await query.fetch();
      var queryU = NCMBUser.query();
      var user = await queryU.fetch();
      if (role1 != null) {
        role1.removeUser(user);
        await role1.save();
        var users = await role1.fetchUser() as List<NCMBUser>;
        expect(users.length, 4);
        for (NCMBUser u in users) {
          await u.delete();
        }
        await role1.delete();
      }
    });
  });
}
