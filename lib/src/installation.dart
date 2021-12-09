import 'object.dart';
import 'query.dart';

class NCMBInstallation extends NCMBObject {
  NCMBInstallation() : super('installations');

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

  static NCMBQuery query() {
    return NCMBQuery('installations');
  }
}
