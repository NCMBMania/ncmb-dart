import 'package:ncmb/ncmb.dart';
import 'dart:io';
import 'dart:convert';

void main() async {
  String str = await new File('example/keys.json').readAsString();
  Map keys = json.decode(str);
  NCMB(keys['applicationKey'], keys['clientKey']);
  var userName = 'aaa';
  var password = 'bbb';
  var user = NCMBUser();
  user.sets({
    'userName': userName,
    'password': password,
  });
  await user.signUpByAccount();
  print(NCMBUser.ncmb!.sessionToken);
  print(user.get('objectId'));
  NCMBUser.ncmb!.sessionToken = null;
  user = await NCMBUser.login(userName, password);
  print(user.get('objectId'));
  await user.delete();
  NCMBUser.logout();
}
