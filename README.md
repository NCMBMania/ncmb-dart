# NCMB for Dart w/ Flutter

Dart and Flutter library for Nifcloud mobile backend(NCMB).

## Usage

### Init

```dart
import 'package:ncmb/ncmb.dart';
NCMB ncmb = new NCMB('YOUR_APPLICATION_KEY', 'YOUR_CLIENT_KEY');
```

### DataStore

#### Create data

```dart
NCMBObject item = ncmb.Object('Item')
  ..set('msg', 'Hello World')
  ..set('array', ['a', 'b'])
  ..set('int', 1)
  ..set('name', 'Atsushi');
await item.save();
debugPrint(item.get('objectId'));
```

#### Update data

```dart
await item.set('name', 'goofmint');
await item.save();
```

#### Delete data

```dart
await item.destroy();
```

#### Retribe data

```dart
NCMBQuery query = ncmb.Query('Item');

// All data
var items = await query.fetchAll();
print(items[0].get('msg'));

// First data
var item2 = await query.fetch();
print(item2.get('msg'));

// Query (Equal)
query.equalTo('objectId', item.get('objectId'));
var item3 = await query.fetch();
print(item3.get('objectId'));

query.clear();
query
  ..notEqualTo('array', ['a', 'b', 'c'])
  ..limit(2)
  ..lessThan('int', 4);
items = await query.fetchAll();
print(items.length);
```

#### ACL

```dart
var acl = NCMBAcl();
acl
  ..setPublicReadAccess(true)
  ..setPublicWriteAccess(false)
  ..setRoleWriteAccess('Admin', true)
  ..setUserWriteAccess('aaaaa', true);
item3.set('acl', acl);
```

#### Special type

```dart
items[0]
  // Class of Datastore
  ..set('item', items[1])
  // DateTime
  ..set('time', DateTime.now())
  // Geo location
  ..set('geo', NCMBGeoPoint(35.658611, 139.745556));
```

## LICENSE

MIT.
