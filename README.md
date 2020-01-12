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
```

## LICENSE

MIT.
