import 'user.dart';

/// NCMBAclクラス
/// ACL（アクセス権限）を扱うためのクラスです
class NCMBAcl {
  /// 権限情報が入るフィールド
  var fields = {};

  /// コンストラクター
  NCMBAcl();

  /// 権限情報をまとめて設定する
  /// [map] 権限情報が入ったマップ
  void sets(Map map) {
    map.forEach((k, v) {
      if (!fields.containsKey(k)) fields[k] = {};
      if (v['read'] == true) fields[k]!['read'] = true;
      if (v['write'] == true) fields[k]!['write'] = true;
    });
  }

  /// 全員に対して読み込み権限を設定する
  /// [allow] 許可する場合はtrue、拒否する場合はfalse
  void setPublicReadAccess(bool allow) {
    roleInit('*');
    fields['*']!['read'] = allow;
  }

  /// 全員に対して書き込み権限を設定する
  /// [allow] 許可する場合はtrue、拒否する場合はfalse
  void setPublicWriteAccess(bool allow) {
    roleInit('*');
    fields['*']!['write'] = allow;
  }

  /// 特定のユーザーに対して読み込み権限を設定する
  /// [user] ユーザー
  /// [allow] 許可する場合はtrue、拒否する場合はfalse
  void setUserReadAccess(NCMBUser user, bool allow) {
    roleInit(user.getString('objectId'));
    fields[user.getString('objectId')]!['read'] = allow;
  }

  /// 特定のユーザーに対して書き込み権限を設定する
  /// [user] ユーザー
  /// [allow] 許可する場合はtrue、拒否する場合はfalse
  void setUserWriteAccess(NCMBUser user, bool allow) {
    roleInit(user.getString('objectId'));
    fields[user.getString('objectId')]!['write'] = allow;
  }

  /// 特定のロールに対して読み込み権限を設定する
  /// [roleName] ロール名
  /// [allow] 許可する場合はtrue、拒否する場合はfalse
  void setRoleReadAccess(String roleName, bool allow) {
    var name = "role:$roleName";
    roleInit(name);
    fields[name]!['read'] = allow;
  }

  /// 特定のロールに対して書き込み権限を設定する
  /// [roleName] ロール名
  /// [allow] 許可する場合はtrue、拒否する場合はfalse
  void setRoleWriteAccess(String roleName, bool allow) {
    var name = "role:$roleName";
    roleInit(name);
    fields[name]!['write'] = allow;
  }

  /// 特定のロールに対する設定を初期化する
  /// [roleName] ロール名
  void roleInit(String roleName) {
    if (!fields.containsKey(roleName)) fields[roleName] = {};
  }

  /// ロールの設定をJSON化する
  dynamic toJson() {
    Map res = {};
    fields.forEach((k, v) {
      if (!res.containsKey(k)) res[k] = {};
      if (v['read'] == true) res[k]['read'] = true;
      if (v['write'] == true) res[k]['write'] = true;
    });
    return Map.from(res)..removeWhere((k, v) => res[k].length == 0);
  }
}
