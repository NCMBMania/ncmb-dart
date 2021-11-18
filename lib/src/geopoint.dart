part of ncmb;

class NCMBGeoPoint {
  double? latitude;
  double? longitude;

  NCMBGeoPoint(double lat, double lng) {
    latitude = lat;
    longitude = lng;
  }

  dynamic toJson() {
    return {'__type': "GeoPoint", 'latitude': latitude, 'longitude': longitude};
  }
}
