part of ncmb;

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
    NCMBInstallation.ncmb = this;
    NCMBFile.ncmb = this;
    NCMBQuery.ncmb = this;
    NCMBRequest.ncmb = this;
    NCMBRole.ncmb = this;
    NCMBPush.ncmb = this;
  }
}
