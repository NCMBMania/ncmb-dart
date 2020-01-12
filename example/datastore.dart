import '../lib/ncmb.dart';
import 'dart:io';
import 'dart:convert';

void main () async{
  String str = await new File('example/keys.json').readAsString();
  Map keys = json.decode(str);
  NCMB ncmb = new NCMB(keys['applicationKey'], keys['clientKey']);
  
  // Create data
  NCMBObject item = ncmb.Object('Item')
    ..set('msg', 'Hello World')
    ..set('array', ['a', 'b'])
    ..set('int', 1)
    ..set('name', 'Atsushi');
  await item.save();
  print(item.get('objectId'));
  
  // Update data
  await item.set('name', 'goofmint');
  await item.save();
  print(item.get('updateDate'));
  
  // Delete data.
  // await item.destroy();
  
  NCMBQuery query = ncmb.Query('Item');
  var items = await query.fetchAll();
  print(items[0].get('msg'));
  var item2 = await query.fetch();
  print(item2.get('msg'));
}

