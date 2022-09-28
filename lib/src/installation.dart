import 'object.dart';
import 'query.dart';

/// デバイストークンを扱うクラス
class NCMBInstallation extends NCMBObject {
  /// コンストラクター
  NCMBInstallation() : super('installations');

  /// デバイストークンを登録する
  /// deviceTokenとdeviveTypeが必須なので、それをチェックして保存する
  @override
  Future<void> save() async {
    if (!super.hasKey('deviceToken')) {
      throw Exception('deviceToken is required.');
    }
    if (!super.hasKey('deviceType')) {
      throw Exception('deviceType is required (ios or android).');
    }
    return super.save();
  }

  /// デバイストークンを検索するクエリークラスを返す
  static NCMBQuery query() {
    return NCMBQuery('installations');
  }
}
