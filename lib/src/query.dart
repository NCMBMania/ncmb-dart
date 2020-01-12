part of ncmb;

class NCMBQuery {
  String _name;
  NCMB _ncmb;
  Map _queries;
  NCMBQuery(NCMB ncmb, String name) {
    _ncmb = ncmb;
    _name = name;
    _queries = {};
  }
  
  Future<NCMBObject> fetch() async {
    _queries['limit'] = 1;
    return (await fetchAll())[0];
  }
  
  Future<List> fetchAll() async {
    var r = new NCMBRequest(_ncmb);
    List ary = await r.get(_name, _queries);
    var results = [];
    ary.forEach((item) {
      var obj = new NCMBObject(_ncmb, _name);
      obj.sets(item);
      results.add(obj);
    });
    return results;
  }
}
