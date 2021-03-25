import '../lib/ncmb.dart';
import 'dart:io';
import 'dart:convert';

void main () async{
  String str = await File('example/keys.json').readAsString();
  Map keys = json.decode(str);
  var ncmb = NCMB(keys['applicationKey'], keys['clientKey']);
  
  // Create data
  var item = ncmb.Object('Item')
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
  // await item.delete();
  
  var query = ncmb.Query('Item');
  var items = await query.fetchAll();
  print(items[0].get('msg'));
  var item2 = await query.fetch();
  print(item2.get('msg'));
  
  query.equalTo('objectId', item.get('objectId'));
  var item3 = await query.fetch();
  print(item3.get('objectId'));
  var acl = ncmb.Acl();
  acl
    ..setPublicReadAccess(true)
    ..setPublicWriteAccess(false)
    ..setRoleWriteAccess('Admin', true)
    ..setUserWriteAccess('aaaaa', true);
  item3
    ..set('new', 'message')
    ..set('acl', acl);
  await item3.save();
  
  query.clear();
  query.equalTo('array', ['a', 'b', 'c']);
  items = await query.fetchAll();
  print(items.length);
  
  query.clear();
  query.notEqualTo('array', ['a', 'b', 'c']);
  items = await query.fetchAll();
  print(items.length);

  query.clear();
  query
    ..notEqualTo('array', ['a', 'b', 'c'])
    ..limit(2)
    ..lessThan('int', 4);
  items = await query.fetchAll();
  print(items.length);
  
  print(items[0].get('acl'));
  
  items[0]
    ..set('item', items[1])
    ..set('time', DateTime.now())
    ..set('geo', ncmb.GeoPoint(35.658611, 139.745556));
  await items[0].save();
}

