/// リレーション用のクラス
class NCMBRelation {
  /// リレーションに関するデータが入るMap
  Map _fields = {};

  /// データを追加する
  /// [obj] 追加するデータ
  void add(obj) {
    var op = 'AddRelation';
    this.set(op, obj);
  }

  /// データを削除する
  /// [obj] 削除するデータ
  void remove(obj) {
    var op = 'RemoveRelation';
    this.set(op, obj);
  }

  /// データを設定する内部用の関数
  void set(op, obj) {
    if (!(obj is List)) {
      obj = [obj];
    }
    var key =
        this._fields.keys.firstWhere((k) => k == '__op', orElse: () => null);
    if (key == null) {
      this._fields = {'__op': op, 'objects': []};
    }
    obj.forEach((o) {
      this._fields['objects'].add(o.toJson());
    });
  }

  /// データをJSON化する
  Map toJson() {
    return this._fields;
  }
}
