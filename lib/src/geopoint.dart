/// 位置情報を扱うクラス
class NCMBGeoPoint {
  /// 緯度
  double? latitude;

  /// 経度
  double? longitude;

  /// コンストラクタ
  /// [lat] 緯度
  /// [lng] 経度
  NCMBGeoPoint(double lat, double lng) {
    latitude = lat;
    longitude = lng;
  }

  /// JSON形式に変換する
  dynamic toJson() {
    return {'__type': "GeoPoint", 'latitude': latitude, 'longitude': longitude};
  }
}
