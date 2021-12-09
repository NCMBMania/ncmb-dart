import 'object.dart';
import 'request.dart';
import 'user.dart';

class NCMB {
  String? applicationKey;
  String? clientKey;
  String? sessionToken;
  String version = '2.0.0';

  NCMB(String applicationKey, String clientKey) {
    this.applicationKey = applicationKey;
    this.clientKey = clientKey;
    NCMBUser.ncmb = this;
    NCMBObject.ncmb = this;
    NCMBRequest.ncmb = this;
  }
}
