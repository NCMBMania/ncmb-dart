import 'dart:async';
import 'object.dart';
import 'query.dart';

/// プッシュ通知を扱うクラス
class NCMBPush extends NCMBObject {
  /// コンストラクター
  NCMBPush() : super('push');

  /// プッシュ通知を保存する
  /// deliveryTimeかimmediateDeliveryFlagは必須なので、それをチェックして保存する
  @override
  Future<void> save() async {
    if (!super.hasKey('deliveryTime') &&
        !super.hasKey('immediateDeliveryFlag')) {
      throw Exception('deliveryTime or immediateDeliveryFlag are required.');
    }
    return super.save();
  }

  /// プッシュ通知を検索するクエリークラスを返す
  static NCMBQuery query() {
    return NCMBQuery('push');
  }
}
