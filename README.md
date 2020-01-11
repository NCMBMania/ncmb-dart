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

## LICENSE

MIT.
