# Example

## DataStore

### Create data

```dart
NCMBObject item = NCMBObject('Item')
  ..set('msg', 'Hello World')
  ..set('array', ['a', 'b'])
  ..set('int', 1)
  ..set('name', 'Atsushi');
await item.save();
debugPrint(item.get('objectId'));
```

### Update data

```dart
await item.set('name', 'goofmint');
await item.save();
```

### Delete data

```dart
await item.delete();
```

### Retribe data

```dart
NCMBQuery query = NCMBQuery('Item');

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

### ACL

```dart
var acl = NCMBAcl();
acl
  ..setPublicReadAccess(true)
  ..setPublicWriteAccess(false)
  ..setRoleWriteAccess('Admin', true)
  ..setUserWriteAccess('aaaaa', true);
item3.set('acl', acl);
```

### Special type

```dart
items[0]
  // Class of Datastore
  ..set('item', items[1])
  // DateTime
  ..set('time', DateTime.now())
  // Geo location
  ..set('geo', NCMBGeoPoint(35.658611, 139.745556));
```


## User

### Register

```dart
var userName = 'aaa';
var password = 'bbb';
var user = NCMBUser();
user
  ..set('userName', userName)
  ..set('password', password);
await user.signUpByAccount();
```

### Login

```dart
var user = await NCMBUser.login(userName, password);
```

### Anonymous Login

```dart
var user = await NCMBUser.loginAsAnonymous();
```

### Check session stats

```dart
var user = await NCMBUser.currentUser();
if (user != null && (await user.enableSession())) {
  print('Login');
} else {
  print('no login');
  await user.logout();
}
```

### Logout

```dart
user.logout();
```

## File

### Upload

Upload binary file

```dart
var fileName = 'dart.png';
var blob = await File(fileName).readAsBytes();
var file = await NCMBFile.upload(fileName, blob);
```

Upload text data as text file.

```dart
test("Upload text file", () async {
var fileName = 'dart.txt';
var file = await NCMBFile.upload(fileName, 'Hello world');
```

Custom mime type.

```dart
var fileName = 'dart.csv';
var file = await NCMBFile.upload(fileName, 'a,b,c', mimeType: 'text/csv');
```

### Download

```dart
var file = await NCMBFile.download('dart.png');
```
