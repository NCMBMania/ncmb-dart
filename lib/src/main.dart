part of ncmb;

class NCMB {
  String applicationKey;
  String clientKey;
  String sessionToken;
  String version = '0.1.2';
  NCMBUser User;
  NCMBInstallation Installation;
  NCMBFile File;
  
  NCMB(String applicationKey, String clientKey) {
    this.applicationKey = applicationKey;
    this.clientKey = clientKey;
    this.User = NCMBUser(this);
    this.Installation = NCMBInstallation(this);
    this.File = NCMBFile(this);
  }
  
  NCMBObject Object(name) {
    return new NCMBObject(this, name);
  }
  
  NCMBQuery Query(name) {
    return new NCMBQuery(this, name);
  }
  
  NCMBAcl Acl() {
    return new NCMBAcl();
  }
  
  NCMBGeoPoint GeoPoint(double lat, double lng) {
    return NCMBGeoPoint(lat, lng);
  }
}
