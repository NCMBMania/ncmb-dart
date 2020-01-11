import '../lib/ncmb.dart';

void main () async{
  NCMB ncmb = new NCMB('YOUR_APPLICATION_KEY', 'YOUR_CLIENT_KEY');
  NCMBObject item = ncmb.Object('Item')
    ..set('msg', 'Hello World')
    ..set('array', ['a', 'b'])
    ..set('int', 1)
    ..set('name', 'Atsushi');
  await item.save();
  print(item.get('objectId'));
}
