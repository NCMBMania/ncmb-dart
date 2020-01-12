part of ncmb;

class NCMB {
  String applicationKey;
  String clientKey;
  NCMB(String applicationKey, String clientKey) {
    this.applicationKey = applicationKey;
    this.clientKey = clientKey;
  }
  
  NCMBObject Object(name) {
    return new NCMBObject(this, name);
  }
  
  NCMBQuery Query(name) {
    return new NCMBQuery(this, name);
  }
}
