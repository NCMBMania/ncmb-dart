part of ncmb;

class NCMBInstallation extends NCMBObject {
  static NCMB? ncmb;
  NCMBInstallation() : super('installations');

  @override
  Future<void> save() async {
    if (this._fields['deviceToken'] == null) {
      throw Exception('deviceToken is required.');
    }
    if (this._fields['deviceType'] == null) {
      throw Exception('deviceType is required (ios or android).');
    }
    return super.save();
  }

  static NCMBQuery query() {
    return NCMBQuery('installations');
  }
}
