import '../lib/ncmb.dart';
import 'dart:io';
import 'dart:convert';

void main () async{
  String str = await new File('example/keys.json').readAsString();
  Map keys = json.decode(str);
  var ncmb = NCMB(keys['applicationKey'], keys['clientKey']);
  
  await ncmb.Installation.register();
}
