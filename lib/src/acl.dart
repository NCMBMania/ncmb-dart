part of ncmb;

class NCMBAcl {
  var fields = {
    '*': {'read': true, 'write': true}
  };

  NCMBAcl();

  void sets(Map map) {
    map.forEach((k, v) {
      if (!fields.containsKey(k)) fields[k] = {};
      if (v['read'] == true) fields[k]!['read'] = true;
      if (v['write'] == true) fields[k]!['write'] = true;
    });
  }

  void setPublicReadAccess(bool allow) {
    fields['*']!['read'] = allow;
  }

  void setPublicWriteAccess(bool allow) {
    fields['*']!['write'] = allow;
  }

  void setUserReadAccess(NCMBUser user, bool allow) {
    roleInit(user.getString('objectId'));
    fields[user.getString('objectId')]!['read'] = allow;
  }

  void setUserWriteAccess(NCMBUser user, bool allow) {
    roleInit(user.getString('objectId'));
    fields[user.getString('objectId')]!['write'] = allow;
  }

  void setRoleReadAccess(String roleName, bool allow) {
    var name = "role:$roleName";
    roleInit(name);
    fields[name]!['read'] = allow;
  }

  void setRoleWriteAccess(String roleName, bool allow) {
    var name = "role:$roleName";
    roleInit(name);
    fields[name]!['write'] = allow;
  }

  void roleInit(String roleName) {
    if (!fields.containsKey(roleName)) fields[roleName] = {};
  }

  dynamic toJson() {
    Map res = {};
    fields.forEach((k, v) {
      if (!res.containsKey(k)) res[k] = {};
      if (v['read'] == true) res[k]['read'] = true;
      if (v['write'] == true) res[k]['write'] = true;
    });
    return Map.from(res)..removeWhere((k, v) => res[k].length == 0);
  }
}
