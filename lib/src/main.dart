part of ncmb;

class NCMB {
  String applicationKey;
  String clientKey;
  String sessionToken;
  String version = '0.1.0';
  
  NCMBUser User;
  NCMBInstallation Installation;
  
  NCMB(String applicationKey, String clientKey) {
    this.applicationKey = applicationKey;
    this.clientKey = clientKey;
    this.User = NCMBUser(this);
    this.Installation = NCMBInstallation(this);
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
