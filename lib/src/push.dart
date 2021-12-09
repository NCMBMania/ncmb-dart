import 'dart:async';
import 'object.dart';
import 'query.dart';

class NCMBPush extends NCMBObject {
  NCMBPush() : super('push');

  @override
  Future<void> save() async {
    if (!super.hasKey('deliveryTime') &&
        !super.hasKey('immediateDeliveryFlag')) {
      throw Exception('deliveryTime or immediateDeliveryFlag are required.');
    }
    return super.save();
  }

  static NCMBQuery query() {
    return NCMBQuery('push');
  }
}
