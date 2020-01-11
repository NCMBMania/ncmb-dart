part of '../ncmb.dart';

class NCMBRequest {
  NCMB _ncmb;
  NCMBRequest(NCMB ncmb) {
    this._ncmb = ncmb;
  }
  
  Future<Map> post(String name, Map fields) async {
    Signature s = new Signature(this._ncmb);
    DateTime time = DateTime.now();
    String signature = s.generate('POST', name, time);
    String url = s.url(name);
    
    final response = await http.post(url,
      body: json.encode(fields),
      headers: {
      "X-NCMB-Application-Key": this._ncmb.applicationKey,
      "X-NCMB-Timestamp": time.toIso8601String(),
      "X-NCMB-Signature": signature,
      "Content-Type": "application/json"
    });
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception(response.body);
    }
  }
  
}