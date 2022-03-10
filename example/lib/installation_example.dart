import 'package:ncmb/ncmb.dart';
import 'dart:io';
import 'dart:convert';

void main() async {
  String str = await new File('example/keys.json').readAsString();
  Map keys = json.decode(str);
  NCMB(keys['applicationKey'], keys['clientKey']);
  var installation = NCMBInstallation();
  installation.set('deviceToken', 'aaaa');
  await installation.save();
}
