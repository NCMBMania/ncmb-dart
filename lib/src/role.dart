import 'main.dart';
import 'user.dart';
import 'object.dart';
import 'query.dart';
import 'relation.dart';

/// ロール用クラス
class NCMBRole extends NCMBObject {
  /// NCMBオブジェクト
  static NCMB? ncmb;

  /// コンストラクター
  /// [roleName] ロール名
  NCMBRole(String roleName) : super('roles', fields: {'roleName': roleName});

  /// 子ロールを追加する
  /// [role] 子ロール
  void addRole(role) {
    var key = 'belongRole';
    add(key, role);
  }

  /// ユーザーを追加する
  /// [user] ユーザー
  void addUser(user) {
    var key = 'belongUser';
    add(key, user);
  }

  /// 子ロールを取得する
  Future<List> fetchRole() async {
    var query = NCMBRole.query();
    query.relatedTo(this, 'belongRole');
    return query.fetchAll();
  }

  /// ユーザーを取得する
  Future<List> fetchUser() async {
    var query = NCMBUser.query();
    query.relatedTo(this, 'belongUser');
    return query.fetchAll();
  }

  /// 子ロール名を削除する
  /// [role] 子ロール
  void removeRole(role) {
    var key = 'belongRole';
    remove(key, role);
  }

  /// ユーザーを削除する
  /// [user] ユーザー
  void removeUser(user) {
    var key = 'belongUser';
    remove(key, user);
  }

  /// 追加用メソッド（内部用）
  /// [key] フィールド名
  /// [obj] 追加するオブジェクト（ロールまたはユーザー）
  void add(key, obj) {
    var exist =
        super.fields.keys.firstWhere((k) => k == key, orElse: () => null);
    if (exist == null || !(super.fields[key] is NCMBRelation)) {
      super.fields[key] = NCMBRelation();
    }
    super.fields[key].add(obj);
  }

  /// 削除用メソッド（内部用）
  /// [key] フィールド名
  /// [obj] 削除するオブジェクト（ロールまたはユーザー）
  void remove(key, obj) {
    var exist =
        super.fields.keys.firstWhere((k) => k == key, orElse: () => null);
    if (exist == null || !(super.fields[key] is NCMBRelation)) {
      super.fields[key] = NCMBRelation();
    }
    super.fields[key].remove(obj);
  }

  /// ロール検索用クエリーを作成する
  static NCMBQuery query() {
    return NCMBQuery('roles');
  }

  /// JSON化する
  Map toJson() {
    return {
      '__type': 'Pointer',
      'className': 'role',
      'objectId': this.get('objectId')
    };
  }

  /// ロールを保存する
  @override
  Future<void> save() async {
    if (!(super.fields['belongUser'] is NCMBRelation)) {
      super.fields.remove('belongUser');
    }
    if (!(super.fields['belongRole'] is NCMBRelation)) {
      super.fields.remove('belongRole');
    }
    return super.save();
  }
}
