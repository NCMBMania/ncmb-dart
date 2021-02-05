part of ncmb;

class NCMBPush extends NCMBObject {
  static NCMB ncmb;
  NCMBPush() : super('push');

  @override
  Future<void> save() async {
    if (this._fields['deliveryTime'] == null && this._fields['immediateDeliveryFlag'] == null) {
      throw Exception('deliveryTime or immediateDeliveryFlag are required.');
    }
    return super.save();
  }

  static NCMBQuery query() {
    return NCMBQuery('push');
  }
}
