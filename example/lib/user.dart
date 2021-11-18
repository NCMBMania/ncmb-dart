import '../lib/ncmb.dart';
import 'dart:io';
import 'dart:convert';

void main () async{
  String str = await new File('example/keys.json').readAsString();
  Map keys = json.decode(str);
  var ncmb = NCMB(keys['applicationKey'], keys['clientKey']);
  var userName = 'aaa';
  var password = 'bbb';
  var user = await ncmb.User.signUpByAccount(userName, password);
  print(ncmb.sessionToken);
  print(user.get('objectId'));
  ncmb.sessionToken = null;
  user = await ncmb.User.login(userName, password);
  print(user.get('objectId'));
  await user.delete();
  user.logout();
}
